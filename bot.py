from telegram import InlineKeyboardButton, InlineKeyboardMarkup, Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes, CallbackQueryHandler,MessageHandler,filters
from supabase import create_client, Client
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from datetime import datetime, timedelta
import re
import time
import pytz
import asyncio
import random
from dotenv import load_dotenv
import os

load_dotenv()
BOT_TOKEN = os.getenv('BOT_TOKEN')
SUPABASE_URL : str = os.getenv('SUPABASE_URL') or ''
SUPABASE_KEY : str =  os.getenv('SUPABASE_KEY') or ''
REGISTER_PASSWORD = os.getenv('REGISTER_PASSWORD')
pending_transactions = {}
waiting_trasaction = {}
user_transactions_page_cache = {}
date_user = {}

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
scheduler = AsyncIOScheduler()
jakarta_tz = pytz.timezone("Asia/Jakarta")

SUCCESS_EFFECT_IDS = {
    "fire" : "5104841245755180586",  # 🔥
    "up" : "5107584321108051014",  # 👍
    "love" : "5159385139981059251",  # ❤️
    "party" : "5046509860389126442"  # 🎉
}

FAIL_EFFECT_IDS  = {
    "down" : "5104858069142078462",  # 👎
    "poo" : "5046589136895476101"  # 💩
}

SPEND_CATEGORIES = {
    "category_food": "Food",
    "category_transport": "Transport",
    "category_entertainment": "Entertainment",
    "category_shopping": "Shopping",
    "category_subscriptions": "Subscriptions",
    "category_health": "Health",
    "category_housing": "Housing",
    "category_other_spend": "Other"
}

GET_CATEGORIES = {
    "category_salary": "Salary",
    "category_freelance": "Freelance",
    "category_gift": "Gift",
    "category_investment": "Investment",
    "category_refund": "Refund",
    "category_other_get": "Other"
}

# INTEREST CYCLE 
async def apply_daily_interest():
    while True:
        print("⏳ Waiting until next interest update...")
        now =  datetime.now(pytz.timezone("Asia/Jakarta"))
        next_run = (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)
        wait_seconds = (next_run - now).total_seconds()

        await asyncio.sleep(wait_seconds)

        # Apply interest
        res = supabase.table("savings_accounts").select("*").execute()
        accounts = res.data
        updated = 0

        for acc in accounts:
            balance = acc["balance"]
            rate = acc.get("interest_rate", 0)
            interest = balance * rate
            new_balance = balance + interest

            # Update balance
            supabase.table("savings_accounts").update({
                "balance": new_balance
            }).eq("id", acc["id"]).execute()

            updated += 1

        print(f"✅ Applied interest to {updated} accounts at {now}")

async def notify_upcoming_bills():
    msg = "🔔 This is your test billing reminder!"
    await app.bot.send_message(chat_id=5770120154, text=msg, parse_mode="Markdown")

# async def notify_upcoming_bills():
    # today = datetime.now().date()
    # tomorrow = today + timedelta(days=1)

    # response = supabase.table("billing_schedule") \
    #     .select("*") \
    #     .eq("due_date", str(tomorrow)) \
    #     .eq("notified", False) \
    #     .execute()

    # for bill in response.data:
    #     user_id = bill["user_id"]
    #     # msg = (
    #     #     f"📅 *Upcoming Billing Reminder!*\n\n"
    #     #     f"🧾 *{bill['billing_name']}*\n"
    #     #     f"💰 Amount: {bill['amount']}\n"
    #     #     f"📆 Due Date: {bill['due_date']}"
    #     # )
    #    
    #     try:
    #         app.bot.send_message(chat_id=5770120154, text=msg, parse_mode="Markdown")
    #         # supabase.table("billing_schedule").update({"notified": True}).eq("id", bill["id"]).execute()
    #     except Exception as e:
    #         print(f"❌ Failed to send reminder to {user_id}: {e}")

# scheduler.add_job(notify_upcoming_bills, 'cron', hour=7)  # runs every day at 07:00

# basic Function 


def get_user_uuid(telegram_id: str):
    result = supabase.table("user").select("id").eq("telegram_id", telegram_id).execute()
    if result.data and len(result.data) > 0:
        return result.data[0]['id']
    return None

def is_valid(telegram_id) :
    user_id = get_user_uuid(telegram_id)
    
    if not user_id:
        return False
    return True

def is_valid_float(text):
    try:
        float_val = float(text)
        return 0 <= float_val <= 100  # Optional: limit range if needed
    except ValueError:
        return False
    
def is_valid_float_nominal(text):
    try:
        float_val = float(text)
        return 0 < float_val   # Optional: limit range if needed
    except ValueError:
        return False

    
#### COMMAND #####



# == /start ====
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    
    name = update.effective_user.first_name 
    await update.message.reply_text(
        f"👋 Hi {name}! Welcome to your personal Finance Tracker Bot.\n\n"
        "To get started, you’ll need a access code from the admin.\n"
        "Once you have it, just type:\n"
        "`/register <access code>`\n\n"
        "Need help? Type `/help` and I’ll guide you through it. 😊\n\n"
    ,message_effect_id=SUCCESS_EFFECT_IDS["up"])

    
# === /register ===
async def register(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.message and update.effective_user :
        telegram_id = str(update.effective_user.id)
        name = update.effective_user.first_name
        # Check password
        if not context.args or context.args[0] != REGISTER_PASSWORD:
            await update.message.reply_text("🚫 Access Denied – Wrong access code")
            return

        # Check if already registered
        result = supabase.table("user").select("id").eq("telegram_id", telegram_id).execute()
        if result.data:
            await update.message.reply_text("✅ Your account are already registered.",message_effect_id=SUCCESS_EFFECT_IDS["up"])
            return

        # Insert new user
        supabase.table("user").insert({
            "telegram_id": telegram_id,
            "name": name
        }).execute()

        await update.message.reply_text(f"🎉 Registration account successful!",message_effect_id=SUCCESS_EFFECT_IDS["party"])


# /add_saving
async def add_saving(update: Update, context: ContextTypes.DEFAULT_TYPE):
    telegram_id = str(update.message.from_user.id)
    
    if not is_valid(telegram_id):
        await update.message.reply_text("❌ You are not registered.")
        return
    
    pending_transactions.pop(telegram_id,None)
    pending_transactions[telegram_id] = {
        "type" : "saving",
        "step" : "saving_name_number",
        "data" : {}
    }
    
    await update.message.reply_text(
        "🏦 Great! What would you like to name your saving account?\n\n"
        "Please enter the account name and number in this format:\n AccountName AccountNumber",
        parse_mode="Markdown"
    )
    
async def handle_interest_button(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()  # Acknowledge the button press

    if telegram_id not in pending_transactions:
        await query.edit_message_text("⚠️ Session expired.")
        return

    if query.data == "interest_yes":
        pending_transactions[telegram_id]["step"] = "input_interest_rate"
        pending_transactions[telegram_id]["data"]["has_interest"] = 'TRUE'
        await query.edit_message_text("📈 What is the interest rate (e.g. 9.2 for 9.2%)? Max 100.", parse_mode="Markdown")
    elif query.data == "interest_no":
        pending_transactions[telegram_id]["step"] = "confirm_saving_data"
        pending_transactions[telegram_id]["data"]["interest_rate"] = 0.0
        pending_transactions[telegram_id]["data"]["has_interest"] = 'FALSE'
        await query.edit_message_text("✅ No interest rate selected.")
        await send_saving_confirmation(update, telegram_id)

async def send_saving_confirmation(update, telegram_id):
    tx = pending_transactions[telegram_id]["data"]

    confirmation_text = (
        "📝 Are you sure you want to save this account?\n\n"
        f"*🏦 Account Name:* {tx['account_name']}\n"
        f"*🔢 Account Number:* {tx['account_number']}\n"
        f"*📌 Priority:* {tx['priority']}"
    )

    if float(tx.get("interest_rate", 0)) > 0:
        confirmation_text += f"\n*📈 Interest Rate:* {tx['interest_rate']}%"

    buttons = [
        [
            InlineKeyboardButton("✅ Yes, Save", callback_data="confirm_saving_yes"),
            InlineKeyboardButton("❌ Cancel", callback_data="confirm_saving_no"),
        ]
    ]
    markup = InlineKeyboardMarkup(buttons)
    query = update.callback_query
    message = update.message or (query.message if query else None)
    
    if query :
        await query.edit_message_text(
            confirmation_text,
            parse_mode="Markdown",
            reply_markup=markup
        )
    elif message:
                await message.reply_text(
            confirmation_text,
            parse_mode="Markdown",
            reply_markup=markup
        )

async def handle_saving_confirmation_button(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()

    if telegram_id not in pending_transactions:
        await query.edit_message_text("⚠️ Session expired.")
        return

    if query.data == "confirm_saving_yes":
        await finish_saving_registration(update, telegram_id)
    elif query.data == "confirm_saving_no":
        await query.edit_message_text("❌ Saving account registration cancelled.")
        pending_transactions.pop(telegram_id, None)
         
async def finish_saving_registration(update, telegram_id):
    query = update.callback_query
    message = update.message or (query.message if query else None)
    data = pending_transactions[telegram_id].get("data")
    
    user_id = get_user_uuid(telegram_id)

    # Check duplicate
    existing = supabase.table("savings_accounts") \
        .select("id") \
        .eq("user_id", user_id) \
        .eq("account_number", data["account_number"]) \
        .filter("account_name", "ilike", data["account_name"]) \
        .execute()

    if existing.data:
        if query:
            await query.edit_message_text(
                f"⚠️ Oops! It looks like you’ve already added a saving account named "
                f"*{data['account_name'].upper()}* with account number ending in *{data['account_number'][-4:]}*.\n",
                parse_mode="Markdown"
            )
        elif message:
            await message.reply_text(
                f"⚠️ Oops! It looks like you’ve already added a saving account named "
                f"*{data['account_name'].upper()}* with account number ending in *{data['account_number'][-4:]}*.\n",
                parse_mode="Markdown"
            )
        pending_transactions.pop(telegram_id, None)
        return


    supabase.table("savings_accounts").insert({
        "user_id": user_id,
        "account_name": data["account_name"].upper(),
        "account_number": data["account_number"],
        "interest_rate": data["interest_rate"],
        "has_interest" : pending_transactions[telegram_id]["data"]["has_interest"],
        "priority": data["priority"],
        "print_name" : f"{data['account_name'].upper()} (•••{data['account_number'][-4:]})"
    }).execute()
    if query:
        await query.edit_message_text(
            f"✅ Saving account *{data['account_name']}* added successfully!",
            parse_mode="Markdown"
        )
    elif message:
         await message.reply_text(
                        f"✅ Saving account *{data['account_name']}* added successfully!",
            parse_mode="Markdown"
        )
    pending_transactions.pop(telegram_id, None)

# === /get ===

async def get_income(update: Update, context: ContextTypes.DEFAULT_TYPE):
    telegram_id = str(update.effective_user.id)
    
    if not is_valid(telegram_id):
        await update.message.reply_text("❌ You are not registered.")
        return
    
    pending_transactions.pop(telegram_id,None)
    user_transactions_page_cache.pop(telegram_id,None)
    
    pending_transactions[telegram_id] = {
        "type" : "income",
        "step" : "input_amount",
        "data" : {}
    }
    # waiting_for_get_input[telegram_id] = True

    await update.message.reply_text(
    "💰 *Nice!* Got some income?\n"
    "Just type the amount or add a note — like:\n `100000 Interest`",
        parse_mode="Markdown"
    )
    
async def confirm_get_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()
    
    if telegram_id not in pending_transactions:
        await query.edit_message_text("⚠️ No pending income.")
        return
    
    tx = pending_transactions[telegram_id].get("data")
    if query.data == "confirm_income_yes":
        # Insert to Supabase (user_id already set during /get)
        supabase.rpc("insert_transaction_and_update_balance", {
        "user_id": tx["user_id"],
        "amount": tx["amount"],
        "item": tx["item"],
        "category": tx.get("category"),
        "tx_type": tx["type"],
        "tx_date": tx["date"].strftime('%Y-%m-%d %H:%M:%S'),
        "saving_id": tx["saving_id"]
        }).execute()

        pending_transactions.pop(telegram_id,None)
        await query.edit_message_text(f"✅ Data saved successfully!")

    elif query.data == "confirm_income_no":
        pending_transactions.pop(telegram_id,None)
        await query.edit_message_text("❌ Cancelled. Income not saved.")
    


# === /Spend ===

async def spend(update: Update, context: ContextTypes.DEFAULT_TYPE):
    
    telegram_id = str(update.effective_user.id)

    # Mark that we expect the next message to be spend input
    if not is_valid(telegram_id):
        await update.message.reply_text("❌ You are not registered.")
        return
    
    pending_transactions.pop(telegram_id,None)
    user_transactions_page_cache.pop(telegram_id,None)
    pending_transactions[telegram_id] = {
        "type" : "outcome",
        "step" : "input_amount",
        "data" : {}
    }

    await update.message.reply_text(
        "💸 *Alright!* What did you spend just now?\n"
        "Type the amount and item — like:\n `10000 pizza`",
        parse_mode="Markdown"
    )
    

async def confirm_spend_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()
    if telegram_id not in pending_transactions:
        await query.edit_message_text("⚠️ No pending spend.")
        return

    tx = pending_transactions[telegram_id].get("data")

    if query.data == "confirm_outcome_yes":
        # Insert to Supabase (user_id already set during /get)
        supabase.rpc("insert_transaction_and_update_balance", {
        "user_id": tx["user_id"],
        "amount": tx["amount"],
        "item": tx["item"],
        "category": tx.get("category"),
        "tx_type": tx["type"],
        "tx_date": tx["date"].strftime('%Y-%m-%d %H:%M:%S'),
        "saving_id": tx["saving_id"]
        }).execute()
        pending_transactions.pop(telegram_id,None)
        await query.edit_message_text(f"✅ Data saved successfully!")
        
    elif query.data == "confirm_outcome_no":
        pending_transactions.pop(telegram_id,None)
        await query.edit_message_text("❌ Cancelled. Spending not saved.")

async def category_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()

    if telegram_id not in pending_transactions:
        await query.edit_message_text("⚠️ No pending transaction.")
        return

    tx = pending_transactions[telegram_id].get("data")
    tx_type = pending_transactions[telegram_id].get("type")
    if tx_type == "outcome" or tx_type == "income" :
        # Choose category map based on type
        if tx_type == "outcome":
            category_map = SPEND_CATEGORIES
        else:
            category_map = GET_CATEGORIES

        if query.data not in category_map:
            await query.edit_message_text("⚠️ Invalid category.")
            return

        tx["category"] = category_map[query.data]
    
        # Show confirm buttons
        confirm_buttons = [
            [
                InlineKeyboardButton("✅ Yes", callback_data=f"confirm_{tx_type}_yes"),
                InlineKeyboardButton("❌ No", callback_data=f"confirm_{tx_type}_no")
            ]
        ]
        date_str = tx["date"].strftime('%d %b %Y - %H:%M:%S')
        type_icon = "💸" if tx["type"] == "spend" else "💰"
        
        if tx["type"] == "spend" :
            text = [f"*📥 Insert this spending?*\n\n"]
            
        elif tx["type"] == "get" :
            text = [f"*📥 Insert this income?*\n\n"]
            
        if tx['item'] == '' :
            text.append(
                    f"🧾 {date_str}\n"
                    f"{type_icon} Amount : {abs(tx['amount'])}\n"
                    f"📂 Category : {tx.get('category', '-')}\n"
                    f"🏦 Saving : {tx.get('saving_name','-')}"
            )
        else :
            text.append(
                    f"🧾 {date_str}\n"
                    f"{type_icon} Amount : {abs(tx['amount'])}\n"
                    f"📦 Item : {tx['item']}\n"
                    f"📂 Category : {tx.get('category', '-')}\n"
                    f"🏦 Saving : {tx.get('saving_name','-')}\n"
            )
            
        text = "\n".join(text) 
        
        await query.edit_message_text(
                text,
                reply_markup=InlineKeyboardMarkup(confirm_buttons),parse_mode="Markdown"
            )
        return
        
    elif tx_type == "manage_tx" :
        
        if pending_transactions.get(telegram_id,{}).get("new_data",{}).get("type") :
            if pending_transactions.get(telegram_id,{}).get("new_data",{}).get("type") == "spend" :
                category_map = SPEND_CATEGORIES
            elif pending_transactions.get(telegram_id,{}).get("new_data",{}).get("type") == "get" :
                category_map = GET_CATEGORIES
        else :
            if tx["type"] == "spend" :
                category_map = SPEND_CATEGORIES
            
            elif tx["type"] == "get" :
                category_map = GET_CATEGORIES

        if tx['category'] == category_map[query.data]:
            
            text = f"⚠️ No changes detected !!!\n\n_You choose {category_map[query.data]}, which is the same as before. Please provide a new amount._"
            await query.edit_message_text(
                    text,
                    parse_mode="Markdown"
                )
        else :
            pending_transactions[telegram_id]["new_data"]["category"] = category_map[query.data]
            
            text = f"✅ Done! The category has been updated."
            await query.edit_message_text(
                    text,
                    parse_mode="Markdown"
                )
        time.sleep(1.5)
        await manage_edit(update,telegram_id)
        return

# DELETE

async def manage_transaction_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    telegram_id = str(update.effective_user.id)
    user_id = get_user_uuid(telegram_id)

    if not user_id:
        await update.message.reply_text("❌ You are not registered.")
        return

    pending_transactions.pop(telegram_id,None)
    pending_transactions[telegram_id] = {
        "type" : "manage_tx",
        "manage_type" : "",
        "step" : "choose_transaction",
        "page" : 0,
        "user_id" : user_id,
        "data" : {}
    }

    await send_transaction_page(update, context, telegram_id, user_id, page=0)
    
async def send_transaction_page(update, context, telegram_id, user_id, page=0,query = None):
    limit = 5
    offset = page * limit

    # Get transactions
    res = supabase.table("transaction") \
        .select("id,user_id,saving_id,date,type,item,amount,category,savings_accounts(account_name,account_number,print_name)") \
        .eq("user_id", user_id) \
        .order("date", desc=True) \
        .range(offset, offset + limit) \
        .execute()
    
    txs = res.data or []
    has_next_page = len(txs) > limit
    txs = txs[:limit]
    
    user_transactions_page_cache.pop(telegram_id,None)
    user_transactions_page_cache[telegram_id] = txs
    if not txs:
        text ="📭 No transactions found."
        markup = None
    
    else :

        text_lines = [f"🛠️ *Great! Let’s pick a transaction to modify:*\n"]
        for i, tx in enumerate(txs, start=1):
            if tx.get('saving_id') :
                account_name = f"{tx['savings_accounts'].get('print_name')}"
            else :
                account_name = 'No Saving'
            t = datetime.fromisoformat(tx['date']).astimezone(pytz.timezone("Asia/Jakarta"))
            date_str = t.strftime("%d %b %Y %H:%M:%S")
            type_icon = "💸" if tx["type"] == "spend" else "💰"
            
            text_lines.append(
                f"*Transaction {i}.*\n"
                f"🧾 {date_str}\n"
                f"📌 Type : {tx['type']}"
            )
            if tx['item'] != '' :
                text_lines.append(
                    f"📦 Item : {tx['item']}"
                )
            
            text_lines.append(
                f"{type_icon} Amount : {abs(int(tx['amount'])):,}\n" 
                f"📂 Category : {tx.get('category', '-')}\n"
                f"🏦 Saving : {account_name}\n"
            )
    
        buttons = []
        if page > 0:
            buttons.append(InlineKeyboardButton("⬅️ Prev", callback_data="delete_prev"))
        if has_next_page:
            buttons.append(InlineKeyboardButton("➡️ Next", callback_data="delete_next"))
        markup = InlineKeyboardMarkup([buttons]) if buttons else None
        text = "\n".join(text_lines) + f"\n*Page {page + 1}*\n\n_Reply with the number of the transaction you want to modify._\n"
    if query:
        await query.edit_message_text(text, parse_mode="Markdown", reply_markup=markup)
    else:
        await update.message.reply_text(text, parse_mode="Markdown", reply_markup=markup)
    
async def delete_pagination_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

    telegram_id = str(query.from_user.id)
    page = pending_transactions[telegram_id].get('page', 0)

    if query.data == "delete_next":
        pending_transactions[telegram_id].update({ 'page' : page + 1})
        await send_transaction_page(update, context, telegram_id, pending_transactions[telegram_id].get('user_id', ''), page + 1,query)
    elif query.data == "delete_prev" and page > 0:
        pending_transactions[telegram_id].update({'page' : page - 1})
        await send_transaction_page(update, context, telegram_id, pending_transactions[telegram_id].get('user_id', ''), page - 1,query)
        
async def confirm_manage_transaction_callback(update: Update, context: ContextTypes.DEFAULT_TYPE) :
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()
    
    tx = pending_transactions.get(telegram_id,{}).get("data")
    
    if not tx:
        await query.edit_message_text("⚠️ Session expired.")
        return
    
    if query.data == "confirm_manage_transaction_yes":
        pending_transactions[telegram_id].update(
            {"step" : "choose_manage_type"}
        )
        
        if tx.get('saving_id') : 
            text = f"✨ What would you like to do with this transaction?\n\n" \
               f"_Please choose how you'd like to manage it._"    
            keyboard = [
                    [InlineKeyboardButton("✏️ Edit", callback_data="manage_type_edit")],
                    [InlineKeyboardButton("🗑️ Delete", callback_data="manage_type_delete")]
            ]
        
        else :
            text =  f"✨ It looks like the saving account linked to this transaction is no longer available, so editing isn't possible.\n\n" \
                    f"_You can go ahead and delete this transaction if it's no longer needed._"
            keyboard = [
                    [InlineKeyboardButton("🗑️ Delete", callback_data="manage_type_delete")]
            ]
        await query.edit_message_text(text,parse_mode="Markdown",reply_markup=InlineKeyboardMarkup(keyboard))
        return
    elif query.data == "confirm_manage_transaction_no":
        await send_transaction_page(update, context, telegram_id, pending_transactions[telegram_id].get("user_id"), pending_transactions[telegram_id].get("page"),query)
        return
        
async def manage_type_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()
    
    tx = pending_transactions.get(telegram_id,{}).get("data")
    
    if not tx:
        await query.edit_message_text("⚠️ Session expired.")
        return
    
    if query.data == "manage_type_edit":
        pending_transactions[telegram_id].update({
            "step" : "processing_trx",
            "manage_type" : "edit",
            "edit_type" : "",
            "new_data" : {}
        })
        
        await manage_edit(update,telegram_id)
        return
    
    elif query.data == "manage_type_delete":
        pending_transactions[telegram_id].update({
            "step" : "processing_trx",
            "manage_type" : "delete"
        })
        
        # Format time
        t = datetime.fromisoformat(tx["date"]).astimezone(pytz.timezone("Asia/Jakarta"))
        date_str = t.strftime("%d %b %Y %H:%M:%S")
        type_icon = "💸" if tx["type"] == "spend" else "💰"
        # Ask for confirmation
        msg = [
            f"❗️ *Are you sure you want to delete this transaction?*\n\n"
            f"🧾 {date_str}\n"
            f"📌 Type : {tx['type']}"
        ]
        
        if tx['item'] != '' :
            msg.append(
                f"📦 Item : {tx['item']}"
            )
            
        msg.append(
            f"{type_icon} Amount : {abs(int(tx['amount']))}\n"
            f"📂 Category : {tx.get('category', '-')}\n"
            f"🏦 Saving : {tx['savings_accounts']}\n\n"
        )
        
        keyboard = [
            [
                InlineKeyboardButton("✅ Yes, Delete", callback_data="confirm_delete_yes"),
                InlineKeyboardButton("❌ No", callback_data="confirm_delete_no"),
            ]
        ]
        text = "\n".join(msg) + "\n_This action is permanent and cannot be undone._"
        await query.edit_message_text(
                    text,
                    parse_mode="Markdown",
                    reply_markup=InlineKeyboardMarkup(keyboard)
                )
        return 
        
async def manage_edit(update,telegram_id):
        tx = pending_transactions.get(telegram_id,{}).get("data")
        new_tx = pending_transactions.get(telegram_id,{}).get("new_data")
        query = update.callback_query
        message = update.message or (query.message if query else None)
            # Format time
        t = datetime.fromisoformat(tx["date"]).astimezone(pytz.timezone("Asia/Jakarta"))
        date_str = t.strftime("%d %b %Y %H:%M:%S")
        type_icon = "💸" if tx["type"] == "spend" else "💰"
        # Ask for confirmation
        msg = [
            f"✏️ *Edit This Transaction*?\n\n"
            f"🧾 {date_str}\n"
            f"📌 Type : {tx['type']} {'→ ' + str(new_tx['type']) if new_tx.get('type') else ''}"
        ]
        
        if tx['item'] != '' or new_tx.get('item','') != '':
            msg.append(
                f"📦 Item : {tx['item']}{'' if tx['item'] else 'None'}{' → ' + str(new_tx['item']) if new_tx.get('item') else ''}"
            )
            
        msg.append(
            f"{type_icon} Amount : {abs(int(tx['amount']))} {'→ ' + str(new_tx['amount']) if new_tx.get('amount') else ''}\n"
            f"📂 Category : {tx.get('category', '-')} {'→ ' + str(new_tx['category']) if new_tx.get('category') else ''}\n"
            f"🏦 Saving : {tx['savings_accounts']} {'→ ' + str(new_tx['savings_accounts']) if new_tx.get('savings_accounts') else ''}\n\n"
        )
        
        keyboard = [
            [
                InlineKeyboardButton("📌 Edit Type", callback_data="edit_type")
            ],
            [
                InlineKeyboardButton("📦 Edit Item Name", callback_data="edit_name")
            ],
            [
                InlineKeyboardButton("💰 Edit Amount", callback_data="edit_amount")
            ],
            [
                InlineKeyboardButton("📂 Edit Category", callback_data="edit_category")
            ],
            [
                InlineKeyboardButton("🏦 Edit Saving", callback_data="edit_saving")
            ],
            [
                InlineKeyboardButton("✅ Confirm", callback_data="edit_confirm"),
                InlineKeyboardButton("🧹 Clear", callback_data="edit_clear"),
                InlineKeyboardButton("❌ Cancel", callback_data="edit_cancel")
            ]
        ]
        text = "\n".join(msg)
        
        if query :
            await query.edit_message_text(
                text,
                parse_mode="Markdown",
                reply_markup=InlineKeyboardMarkup(keyboard)
            )
        elif message:
            await message.reply_text(
                text,
                parse_mode="Markdown",
                reply_markup=InlineKeyboardMarkup(keyboard)
            )
        return

async def confirm_edit_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()

    tx = pending_transactions.get(telegram_id,{}).get("data")
    
    if not tx:
        await query.edit_message_text("⚠️ Session expired.")
        return
    
    if query.data == "edit_amount":
        pending_transactions[telegram_id].update({
            "edit_type" : "amount",
        })
        await query.edit_message_text(
                f"💰 How much would you like to update the amount to?\n\n"
                f"_(Please enter a new amount different from the current one.)_",
                parse_mode="Markdown",
            )
        return
    elif query.data == "edit_name":
        pending_transactions[telegram_id].update({
            "edit_type" : "name",
        })
        await query.edit_message_text(
                f"📦 What would you like to change the name to?\n\n"
                f"_(Please enter a new name different from the current one.)_",
                parse_mode="Markdown",
            )
        return
    elif query.data == "edit_type":
        pending_transactions[telegram_id].update({
            "edit_type" : "type",
        })
         
        if tx["type"] == "spend":
            if pending_transactions[telegram_id]["new_data"].get("type",'') == 'get':
                await query.edit_message_text(
                    f"Transaction type same as orginal",
                    parse_mode="Markdown",
                )
                time.sleep(1.5)
                await manage_edit(update,telegram_id)
                return
            pending_transactions[telegram_id]["new_data"].update({
                "type" : 'get'
            })
        elif tx["type"] == "get":
            if pending_transactions[telegram_id]["new_data"].get("type",'') == 'spend':
                await query.edit_message_text(
                    f"Transaction type same as orginal",
                    parse_mode="Markdown",
                )
                time.sleep(1.5)
                await manage_edit(update,telegram_id)
                return
            pending_transactions[telegram_id]["new_data"].update({
                "type" : 'spend'
            })
        
        await query.edit_message_text(
            f"✅ Done! The type has been updated.",
            parse_mode="Markdown",
        )
        time.sleep(1.5)
        await manage_edit(update,telegram_id)
        return
                
    elif query.data == "edit_category":
        pending_transactions[telegram_id].update({
            "edit_type" : "category",
        })
        if pending_transactions.get(telegram_id,{}).get("new_data",{}).get("type") :
            if pending_transactions.get(telegram_id,{}).get("new_data",{}).get("type") == "spend":
               keyboard = [
                    [InlineKeyboardButton("🍔 Food", callback_data="category_food"),
                    InlineKeyboardButton("🚗 Transport", callback_data="category_transport")],
                    [InlineKeyboardButton("🎬 Entertainment", callback_data="category_entertainment"),
                    InlineKeyboardButton("🛍 Shopping", callback_data="category_shopping")],
                    [InlineKeyboardButton("📱 Subscriptions", callback_data="category_subscriptions"),
                    InlineKeyboardButton("💊 Health", callback_data="category_health")],
                    [InlineKeyboardButton("🏠 Housing", callback_data="category_housing"),
                    InlineKeyboardButton("📦 Other", callback_data="category_other_spend")]
                ] 
            elif pending_transactions.get(telegram_id,{}).get("new_data",{}).get("type") == "get":
                keyboard = [
                    [InlineKeyboardButton("💼 Salary", callback_data="category_salary"),
                    InlineKeyboardButton("🧾 Freelance", callback_data="category_freelance")],
                    [InlineKeyboardButton("🎁 Gift", callback_data="category_gift"),
                    InlineKeyboardButton("📈 Investment", callback_data="category_investment")],
                    [InlineKeyboardButton("💸 Refund", callback_data="category_refund"),
                    InlineKeyboardButton("📦 Other", callback_data="category_other_get")]
                ]
        else :
            if tx["type"] == "spend" :
                keyboard = [
                        [InlineKeyboardButton("🍔 Food", callback_data="category_food"),
                        InlineKeyboardButton("🚗 Transport", callback_data="category_transport")],
                        [InlineKeyboardButton("🎬 Entertainment", callback_data="category_entertainment"),
                        InlineKeyboardButton("🛍 Shopping", callback_data="category_shopping")],
                        [InlineKeyboardButton("📱 Subscriptions", callback_data="category_subscriptions"),
                        InlineKeyboardButton("💊 Health", callback_data="category_health")],
                        [InlineKeyboardButton("🏠 Housing", callback_data="category_housing"),
                        InlineKeyboardButton("📦 Other", callback_data="category_other_spend")]
                    ]
                
            elif tx["type"] == "get" :
                keyboard = [
                        [InlineKeyboardButton("💼 Salary", callback_data="category_salary"),
                        InlineKeyboardButton("🧾 Freelance", callback_data="category_freelance")],
                        [InlineKeyboardButton("🎁 Gift", callback_data="category_gift"),
                        InlineKeyboardButton("📈 Investment", callback_data="category_investment")],
                        [InlineKeyboardButton("💸 Refund", callback_data="category_refund"),
                        InlineKeyboardButton("📦 Other", callback_data="category_other_get")]
                    ]
            
        await query.edit_message_text(
                f"📂 What category would you like to change it to?\n\n" \
                f"_(Please select a new category different from the current one.)_",
                reply_markup=InlineKeyboardMarkup(keyboard),
                parse_mode="Markdown",
            )
        return
    elif query.data == "edit_saving":
        pending_transactions[telegram_id].update({
            "edit_type" : "saving",
        })
        user_transactions_page_cache.pop(telegram_id,None)
        res = supabase.table("savings_accounts") \
                .select("*") \
                .eq("user_id", tx['user_id']) \
                .neq("id", tx.get('saving_id',None)) \
                .order("priority", desc=False) \
                .order("account_name", desc=False) \
                .execute()
        
        txs = res.data or []
        user_transactions_page_cache[telegram_id] = txs
        
        if not txs:
            text ="💡 It looks like you only have one saving account.\n" \
                        "You can create one now by using:\n" \
                        "/add_saving"
        
        else :
            text_line = [f"🏦 Great! Let’s pick a savings account to continue:\n\n"]
            for i, tx in enumerate(txs, start=1):
                text_line.append(
                f"*{i}.* {tx['account_name'].upper()} (•••{tx['account_number'][-4:]})\n"
                )
            text = "".join(text_line) + "\n💬 Please _reply_ with the number of the savings account you want to use."           
        
        await query.edit_message_text(
                text,
                parse_mode="Markdown",
            )
        return
    
    elif query.data == "edit_clear":
        pending_transactions[telegram_id].update({
            "new_data" : {}
        })
        await query.edit_message_text(
                f"🧹 All edits have been cleared. You're back to the original transaction.",
                parse_mode="Markdown",
            ) 
        time.sleep(1.5)
        await manage_edit(update,telegram_id)
        return
    elif query.data == "edit_cancel":
        pending_transactions.pop(telegram_id,None)
        user_transactions_page_cache.pop(telegram_id,None)
        await query.edit_message_text(
                f"❌ Edit canceled.",
                parse_mode="Markdown",
            ) 
        return
    elif query.data == "edit_confirm": 
        new_tx = pending_transactions.get(telegram_id,{}).get("new_data")
        if not new_tx :
            await query.edit_message_text( 
                f"⚠️ Nothing’s been updated yet — change something before hitting submit!",
                parse_mode="Markdown",
            ) 
            time.sleep(1.5)
            await manage_edit(update,telegram_id)
            return
        
        final = {}
        
        if not new_tx.get('type',None):
            final['type'] = tx['type']
        else :
            final['type'] = new_tx['type']
            
        if not new_tx.get('amount',None):
            final['amount'] = tx['amount']
        else :
            final['amount'] = new_tx['amount']
        
        if final['type'] == 'spend':
            final['amount'] = -int(abs(final['amount']))
        elif final['type'] == 'get':
            final['amount'] = int(abs(final['amount']))
            
        if not new_tx.get('category',None):
            final['category'] = tx['category']
        else :
            final['category'] = new_tx['category']
            
        if final['type'] == 'spend':
            if final['category'] not in SPEND_CATEGORIES.values():
                await query.edit_message_text(
                    f"⚠️ The selected category doesn't match the transaction type.\n",
                    parse_mode="Markdown",
                    ) 
                time.sleep(1.5)
                await manage_edit(update,telegram_id)
                return
        elif final['type'] == 'get':
            if final['category'] not in GET_CATEGORIES.values():
                await query.edit_message_text(
                    f"⚠️ The selected category doesn't match the transaction type.\n",
                    parse_mode="Markdown",
                    ) 
                time.sleep(1.5)
                await manage_edit(update,telegram_id)
                return
             
        if not new_tx.get('saving_id',None):
            final['saving_id'] = tx['saving_id']
        else :
            final['saving_id'] = new_tx['saving_id']
            
        if not new_tx.get('item',None):
            final['item'] = tx['item']
        else :
            final['item'] = new_tx['item']
            

        supabase.rpc("update_transaction_and_update_balance",{
        "tx_id" : tx['id'],
        "new_amount" : final['amount'],
        "new_category" : final['category'],
        "new_type" : final['type'],
        "new_saving_id" : final['saving_id'],
        "new_item" : final['item']
        }).execute()
        
        pending_transactions.pop(telegram_id,None)
        user_transactions_page_cache.pop(telegram_id,None)
        
        await query.edit_message_text(
            f"🎉 Your changes have been saved!",
            parse_mode="Markdown",
        ) 
        return
    
async def confirm_delete_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()

    tx = pending_transactions.get(telegram_id,{}).get("data")

    if not tx:
        await query.edit_message_text("⚠️ No pending transaction to delete.")
        return

    if query.data == "confirm_delete_yes":

        # Safely delete and update balance via RPC
        supabase.rpc("delete_transaction_and_update_balance", {
            "tx_id": int(tx["id"])
        }).execute()
        pending_transactions.pop(telegram_id,None)
        user_transactions_page_cache.pop(telegram_id,None)
        await query.edit_message_text("✅ Transaction deleted.")

    elif query.data == "confirm_delete_no":
        pending_transactions.pop(telegram_id,None)
        user_transactions_page_cache.pop(telegram_id,None)
        await query.edit_message_text("❌ Delete canceled.")     
        
# MANAGE SAVING
async def manage_saving_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    telegram_id = str(update.effective_user.id)
    user_id = get_user_uuid(telegram_id)

    if not user_id:
        await update.message.reply_text("❌ You are not registered.")
        return

    pending_transactions.pop(telegram_id,None)
    pending_transactions[telegram_id] = {
        "type" : "manage_sv",
        "manage_type" : "",
        "step" : "selecting_saving",
        "data" : {}
    }
    
    res = supabase.table("savings_accounts") \
                .select("id,account_name,account_number,priority,balance,interest_rate,print_name") \
                .eq("user_id", user_id) \
                .order("priority", desc=False) \
                .order("account_name", desc=False) \
                .execute()
                
    txs = res.data or []
    user_transactions_page_cache.pop(telegram_id,None)
    user_transactions_page_cache[telegram_id] = txs
    if not txs:
        text ="📭 No saving found." 
    
    else :
        text_line = [f"🏦 Great! Let’s pick a savings account to modify:\n\n"]
        for i, tx in enumerate(txs, start=1):
            text_line.append(
            f"*{i}.* {tx['print_name']}\n"
            )   
        text = "".join(text_line) + "\n💬 Just send me the number of the savings account you want to pick — like 1 or 2 — and we’ll go from there!"
        
    await update.message.reply_text(text,parse_mode="Markdown") 
    
    
async def manage_sv_type_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()
    
    tx = pending_transactions.get(telegram_id,{}).get("data")
    
    if not tx:
        await query.edit_message_text("⚠️ Session expired.")
        return
    
    if query.data == "manage_sv_type_edit":
        pending_transactions[telegram_id].update({
            "step" : "processing_sv",
            "manage_type" : "edit",
            "edit_type" : "",
            "new_data" : {}
        })
        
        await manage_edit_sv(update,telegram_id)
        return
    
    elif query.data == "manage_sv_type_delete":
        pending_transactions[telegram_id].update({
            "step" : "processing_sv",
            "manage_type" : "delete"
        })
        
        # Format time
        # Ask for confirmation
        msg = [
            f"❗️*Are you sure you want to delete saving {tx['account_name'].upper()} (•••{tx['account_number'][-4:]}) ?*\n"
        ]
        
        text = "\n".join(msg) + "\n_This action is permanent and cannot be undone._"
        keyboard = [
            [
                InlineKeyboardButton("✅ Yes, Delete", callback_data="confirm_delete_sv_yes"),
                InlineKeyboardButton("❌ No", callback_data="confirm_delete_sv_no"),
            ]
        ]
        
        await query.edit_message_text(
                    text,
                    parse_mode="Markdown",
                    reply_markup=InlineKeyboardMarkup(keyboard)
                )
        return 

async def confirm_delete_sv_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()

    sv = pending_transactions.get(telegram_id,{}).get("data")

    if not sv:
        await query.edit_message_text("⚠️ No pending transaction to delete.")
        return

    if query.data == "confirm_delete_sv_yes":

        # Safely delete and update balance via RPC
        supabase.rpc("delete_saving_and_update_balance", {
            "sv_id": int(sv["id"])
        }).execute()
        pending_transactions.pop(telegram_id,None)
        user_transactions_page_cache.pop(telegram_id,None)
        await query.edit_message_text("✅ Transaction deleted.")
        return

    elif query.data == "confirm_delete_sv_no":
        pending_transactions.pop(telegram_id,None)
        user_transactions_page_cache.pop(telegram_id,None)
        await query.edit_message_text("❌ Delete canceled.")     
        return
    
async def manage_edit_sv(update,telegram_id):
    
    tx = pending_transactions.get(telegram_id,{}).get("data")
    new_tx = pending_transactions.get(telegram_id,{}).get("new_data")
    query = update.callback_query
    message = update.message or (query.message if query else None)
        # Format time
    # Ask for confirmation
    if new_tx.get('account_name') or new_tx.get('account_number') :
        text = f"✏️ *Edit This Saving*?\n\n" \
            f"🏦 Saving Account : {tx['account_name'].upper()} (•••{tx['account_number'][-4:]}) {'→' if new_tx.get('account_name') or new_tx.get('account_number') else ''} {str(['account_name'].upper()) if new_tx.get('account_name') else str(tx['account_name'].upper())} {'(•••' + str(new_tx['account_number'][-4:]) + ')' if new_tx.get('account_number') else '(•••' + str(tx['account_number'][-4:]) + ')'}\n" \
            f"💰 Balance : {tx['balance']} {'→ ' + str(new_tx['balance']) if new_tx.get('balance') else ''}\n" \
            f"📈 Interest Rate : {tx['interest_rate']} {'→ ' + str(new_tx['interest_rate']) if new_tx.get('interest_rate') else ''}\n" \
            f"📌 priority : {tx['priority']} {'→ ' + str(new_tx['priority']) if new_tx.get('priority') else ''}\n"
    
    else :
        text = f"✏️ *Edit This Saving*?\n\n" \
            f"🏦 Saving Account : {tx['account_name'].upper()} (•••{tx['account_number'][-4:]})\n" \
            f"💰 Balance : {tx['balance']} {'→ ' + str(new_tx['balance']) if new_tx.get('balance') else ''}\n" \
            f"📈 Interest Rate : {tx['interest_rate']} {'→ ' + str(new_tx['interest_rate']) if new_tx.get('interest_rate') else ''}\n" \
            f"📌 priority : {tx['priority']} {'→ ' + str(new_tx['priority']) if new_tx.get('priority') else ''}\n"
    
    keyboard = [
        [
            InlineKeyboardButton("🏦 Edit Account Name", callback_data="edit_sv_name")
        ],
        [
            InlineKeyboardButton("🔢 Edit Account Number", callback_data="edit_sv_number")
        ],
        [
            InlineKeyboardButton("💰 Edit Balance", callback_data="edit_sv_balance")
        ],
        [
            InlineKeyboardButton("📈 Edit Interest Rate", callback_data="edit_sv_interest")
        ],
        [
            InlineKeyboardButton("📌 Edit Priority", callback_data="edit_sv_priority")
        ],
        [
            InlineKeyboardButton("✅ Confirm", callback_data="edit_sv_confirm"),
            InlineKeyboardButton("🧹 Clear", callback_data="edit_sv_clear"),
            InlineKeyboardButton("❌ Cancel", callback_data="edit_sv_cancel")
        ]
    ]
    
    if query :
        await query.edit_message_text(
            text,
            parse_mode="Markdown",
            reply_markup=InlineKeyboardMarkup(keyboard)
        )
    elif message:
        await message.reply_text(
            text,
            parse_mode="Markdown",
            reply_markup=InlineKeyboardMarkup(keyboard)
        )
    return   

async def confirm_edit_sv_callback(update: Update, context: ContextTypes.DEFAULT_TYPE) :
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()
    
    tx = pending_transactions.get(telegram_id,{}).get("data")
    
    if not tx:
        await query.edit_message_text("⚠️ Session expired.")
        return
    
    if query.data == "edit_sv_name":
        pending_transactions[telegram_id].update({
            "edit_type" : "name"
        })
        return
    elif query.data == "edit_sv_number":
        pending_transactions[telegram_id].update({
            "edit_type" : "number"
        })
        return
    elif query.data == "edit_sv_balance":
        pending_transactions[telegram_id].update({
            "edit_type" : "balance"
        })
        return
    elif query.data == "edit_sv_interest":
        pending_transactions[telegram_id].update({
            "edit_type" : "interest"
        })
        return
    elif query.data == "edit_sv_priority":
        pending_transactions[telegram_id].update({
            "edit_type" : "priority"
        })
        return
    elif query.data == "edit_sv_clear":
        pending_transactions[telegram_id].update({
            "new_data" : {}
        })
        await query.edit_message_text(
                f"🧹 All edits have been cleared. You're back to the original transaction.",
                parse_mode="Markdown",
            ) 
        time.sleep(1.5)
        await manage_edit(update,telegram_id)
        return
    elif query.data == "edit_sv_cancel":
        pending_transactions.pop(telegram_id,None)
        user_transactions_page_cache.pop(telegram_id,None)
        await query.edit_message_text(
                f"❌ Edit canceled.",
                parse_mode="Markdown",
            ) 
        return
    elif query.data == "edit_sv_confirm": 
        new_tx = pending_transactions.get(telegram_id,{}).get("new_data")
        if not new_tx :
            await query.edit_message_text( 
                f"⚠️ Nothing’s been updated yet — change something before hitting submit!",
                parse_mode="Markdown",
            ) 
            time.sleep(1.5)
            await manage_edit(update,telegram_id)
            return
        
        final = {}
        
        if not new_tx.get('type',None):
            final['type'] = tx['type']
        else :
            final['type'] = new_tx['type']
            
        if not new_tx.get('amount',None):
            final['amount'] = tx['amount']
        else :
            final['amount'] = new_tx['amount']
        
        if final['type'] == 'spend':
            final['amount'] = -int(abs(final['amount']))
        elif final['type'] == 'get':
            final['amount'] = int(abs(final['amount']))
            
        if not new_tx.get('category',None):
            final['category'] = tx['category']
        else :
            final['category'] = new_tx['category']
            
        if final['type'] == 'spend':
            if final['category'] not in SPEND_CATEGORIES.values():
                await query.edit_message_text(
                    f"⚠️ The selected category doesn't match the transaction type.\n",
                    parse_mode="Markdown",
                    ) 
                time.sleep(1.5)
                await manage_edit(update,telegram_id)
                return
        elif final['type'] == 'get':
            if final['category'] not in GET_CATEGORIES.values():
                await query.edit_message_text(
                    f"⚠️ The selected category doesn't match the transaction type.\n",
                    parse_mode="Markdown",
                    ) 
                time.sleep(1.5)
                await manage_edit(update,telegram_id)
                return
             
        if not new_tx.get('saving_id',None):
            final['saving_id'] = tx['saving_id']
        else :
            final['saving_id'] = new_tx['saving_id']
            
        if not new_tx.get('item',None):
            final['item'] = tx['item']
        else :
            final['item'] = new_tx['item']
            

        supabase.rpc("update_transaction_and_update_balance",{
        "tx_id" : tx['id'],
        "new_amount" : final['amount'],
        "new_category" : final['category'],
        "new_type" : final['type'],
        "new_saving_id" : final['saving_id'],
        "new_item" : final['item']
        }).execute()
        
        pending_transactions.pop(telegram_id,None)
        user_transactions_page_cache.pop(telegram_id,None)
        
        await query.edit_message_text(
            f"🎉 Your changes have been saved!",
            parse_mode="Markdown",
        ) 
        return
    
async def config(update: Update, context: ContextTypes.DEFAULT_TYPE) :
    telegram_id = str(update.effective_user.id)
    
    if not is_valid(telegram_id):
        await update.message.reply_text("❌ You are not registered.")
        return
    
    pending_transactions.pop(telegram_id,None)
    pending_transactions[telegram_id] = {
        "type" : "config",
        "step" : "enter_password",
        "new_password" : ""
    }
    
    await update.message.reply_text("🔑 Please enter the access code to continue")
    
   
async def selecting_config(update: Update, context: ContextTypes.DEFAULT_TYPE):
    telegram_id = str(update.effective_user.id)
    query = update.callback_query
    message = update.message or (query.message if query else None)
    
    keyboard = [
    [InlineKeyboardButton("🌐 Database URL", callback_data="config_link"),
     InlineKeyboardButton("🔑 Database Key", callback_data="config_key")],
    [InlineKeyboardButton("🔑 Access Key", callback_data="config_access")],
    [InlineKeyboardButton("Done", callback_data="config_done")]
]
    if query :
        await query.edit_message_text(
                    f"⚙️ Which *configuration* would you like to change ?",
                    reply_markup=InlineKeyboardMarkup(keyboard),
                    parse_mode="Markdown",
                )
    elif message:
        await message.reply_text(
                    f"⚙️ Which *configuration* would you like to change ?",
                    reply_markup=InlineKeyboardMarkup(keyboard),
                    parse_mode="Markdown",
                )
    return
    
async def config_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    user_id = get_user_uuid(telegram_id)
    await query.answer()
    
    if query.data == 'config_link':
        pending_transactions[telegram_id].update({
            "step" : "link_update"
        })
        await query.edit_message_text("🌐 What’s the new database link ?") 
   
        
    elif query.data == 'config_key':
        pending_transactions[telegram_id].update({
            "step" : "link_key"
        })
        await query.edit_message_text("🔑 What’s the new database key ?")
    
    elif query.data == 'config_access':
        pending_transactions[telegram_id].update({
            "step" : "access"
        })
        await query.edit_message_text("🔑 What’s the new access key ?")
    
    elif query.data == 'config_done':
        passkey = pending_transactions[telegram_id].get("new_password",None)
        if passkey:
            supabase.table('user').update({'access_key': passkey}).eq('id', user_id).execute()
        await query.edit_message_text("🎉 All your changes are saved!")
    return  

## TRANSFER
async def transfer(update : Update,context:ContextTypes.DEFAULT_TYPE):
    telegram_id = str(update.effective_user.id)
    user_id = get_user_uuid(telegram_id)
    pending_transactions.pop(telegram_id,None)
    user_transactions_page_cache.pop(telegram_id,None)
    pending_transactions[telegram_id] = {
        "type" : "tranfer",
        "step" : "select_source",
        "data_source" : {},
        "data_dest" : {},
        "amount" : 0
    }
    
    res = supabase.table("savings_accounts") \
        .select("id, account_name, account_number,print_name,balance") \
        .eq("user_id", user_id) \
        .execute()
        
    svs =  res.data or []
    user_transactions_page_cache[telegram_id] = svs
    
    if not svs :
        txt = "💡 It looks like you haven’t created a savings account yet.\n\n" \
                        "You can create one now by using:\n" \
                        "/add_saving"

    else :
        msg = ["✨ *Let’s get started!*\n\nSelect your *source* account below:\n\n"]
                
        for i,sv in enumerate(svs,start=1):
            balance = f"Rp. {int(sv['balance']):,}" if sv['balance'] > 0 else "No Balance"
            msg.append(f"*{i}. {sv['print_name']}* - {balance}\n")
            
       
        txt = ''.join(msg) + "\n👉 Reply with the number of the account you want.\nFor example, type 1 for the first account."
    
    
    await update.message.reply_text(txt,parse_mode="Markdown")

async def confirm_tranfer_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    telegram_id = str(query.from_user.id)
    await query.answer()
    
    if query.data == "trf_yes":
        try :
            supabase.rpc("transfer_amount",{
                "sv_id_src" : pending_transactions[telegram_id]["data_source"]['id'],
                "sv_id_dst" : pending_transactions[telegram_id]["data_dest"]['id'],
                "amount" : pending_transactions[telegram_id]["amount"]
            }).execute()
            
            await query.edit_message_text("🎉 Your transfer was successful!")
            
        except Exception as e :
            await query.edit_message_text(f"⚠️ Oops! The transfer didn’t go through.")
    
    elif query.data == "trf_no":
        pending_transactions.pop(telegram_id,None)
        user_transactions_page_cache.pop(telegram_id,None)
        await query.edit_message_text(
                f"❌ Transfer canceled. No changes were made.",
                parse_mode="Markdown",
            ) 
        return


async def add_bill(update: Update, context: ContextTypes.DEFAULT_TYPE):
    telegram_id = str(update.effective_user.id)
    user_id = get_user_uuid(telegram_id)
    pending_transactions.pop(telegram_id,None)
    user_transactions_page_cache.pop(telegram_id,None)
    pending_transactions[telegram_id] = {
        "type" : "add_bill",
        "step" : "amount",
        "data_saving" : {}
    }
    
    
    await update.message.reply_text("📝 Let’s Add a Bill!.\n\n💸How much is it?",parse_mode="Markdown")
    
# Handle text  
  
async def handle_text_input(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global SUPABASE_URL
    global SUPABASE_KEY
    global supabase
    global REGISTER_PASSWORD
    telegram_id = str(update.effective_user.id)
    text = update.message.text.strip()
    try :
        user_id = get_user_uuid(telegram_id)
    except :
        user_id = None
        
    try :
        cek = pending_transactions[telegram_id]
    except :
        await update.message.reply_text("🤖 Sorry, I didn’t understand that. Please use a command like /spend, /get, or /history.")
        return
    
    if pending_transactions[telegram_id].get('type') == "saving":
        step = pending_transactions[telegram_id].get("step")
                # Handle saving account flow

        if step == "saving_name_number":
            match = re.match(r'(.+)\s+(\d+)', text)
            if not match:
                await update.message.reply_text("⚠️ Oops! Please enter the account details in this format:\n"
                                                "`AccountName AccountNumber`\n"
                                                "For example: BRI 1234567890", parse_mode="Markdown")
                return
            name, number = match.groups()
            pending_transactions[telegram_id]["data"].update({
                "account_name": name,
                "account_number": number
            })

            pending_transactions[telegram_id]["step"] = "setting_priority"


            await update.message.reply_text(
                "📌 Set the priority for this savings account:\n\n"

                "Choose a number from 1 to 10 based on how often you use this account:\n\n"

                "🔴 1–3 → High Priority (used very often — main account)\n"
                "🟡 4–6 → Medium Priority (used sometimes)\n"
                "🟢 7–10 → Low Priority (used rarely — backup or long-term)\n\n"

                "💬 Just reply with the number!\n",
                parse_mode="Markdown"
            )
            return
        
        if step == "setting_priority" :
            if text.isdigit():
                if int(text) > 10 :
                    await update.message.reply_text(
                    "📌 Pick a priority by sending a number (1 = highest, 10 = lowest)",
                    parse_mode="Markdown"
                     )
                    return

                pending_transactions[telegram_id]["step"] = "ask_interest"
                pending_transactions[telegram_id]["data"].update({
                "priority": int(text)
                })
                
                buttons = [            
                        [
                    InlineKeyboardButton("✅ Yes", callback_data="interest_yes"),
                    InlineKeyboardButton("❌ No", callback_data="interest_no"),
                        ]]
                markup = InlineKeyboardMarkup(buttons)

                await update.message.reply_text(
                    "💳 Does this saving account have an interest rate?",
                    reply_markup=markup, parse_mode="Markdown"
                )
                return         
                
            else :
                await update.message.reply_text(
                "📌 Just send the number of your priority savings account.",
                parse_mode="Markdown"
            )
                return
        if step == "input_interest_rate":
            if is_valid_float(text):
                pending_transactions[telegram_id]["data"].update({
                    "interest_rate" : text
                })
                await send_saving_confirmation(update, telegram_id)
                return  
            else :
                await update.message.reply_text("⚠️ Max interest rate is 100%. Please input a valid number.")
                return
                
            
    # --- Handle Spend ---
    if  pending_transactions[telegram_id].get('type') == 'outcome':
        step = pending_transactions[telegram_id].get("step")
        
        if step == 'input_amount':
            match = re.match(r'(\d+)\s+(.+)', text)
            if not match:
                await update.message.reply_text("⚠️ Oops! Please enter the amount and item name in this format:\n"
                                                "`Amount ItemName`\n"
                                                "For example: 25000 Groceries", parse_mode="Markdown")
                return

            amount, item = match.groups()
            msg_date = update.message.date.astimezone(pytz.timezone("Asia/Jakarta"))
            date_str = msg_date.strftime('%d %b %Y %H:%M')

            pending_transactions[telegram_id]["data"].update({
                "user_id": user_id,
                "amount": -float(amount),
                "item": item,
                "type": "spend",
                "date": msg_date
            })

            res = supabase.table("savings_accounts") \
                .select("id,account_name,account_number") \
                .eq("user_id", user_id) \
                .order("priority", desc=False) \
                .order("account_name", desc=False) \
                .execute()
                
            txs = res.data or []
            user_transactions_page_cache[telegram_id] = txs
            if not txs:
                text ="💡 It looks like you haven’t created a savings account yet.\n" \
                        "You can create one now by using:\n" \
                        "/add_saving"
            
            
            else :
                text_line = [f"🏦 Great! Let’s pick a savings account to continue:\n\n"]
                for i, tx in enumerate(txs, start=1):
                    text_line.append(
                    f"*{i}.* {tx['account_name'].upper()} (•••{tx['account_number'][-4:]})\n"
                    )
                text = "".join(text_line) + "\n💬 Please _reply_ with the number of the savings account you want to use."
                pending_transactions[telegram_id]["step"] = "select_saving"
            await update.message.reply_text(text,parse_mode="Markdown")
            return
        
        if step == 'select_saving':
            
            if text.isdigit():
                txs = user_transactions_page_cache.get(telegram_id)
                
                index = int(text) - 1
                if not txs or index >= len(txs):
                    await update.message.reply_text("⚠️ Invalid selection.")
                    return
                
                tx = txs[index]
                pending_transactions[telegram_id]["data"].update({
                "saving_id" : int(tx['id']),
                "saving_name" : f"{tx['account_name']} (•••{tx['account_number'][-4:]})"
                })
                
                keyboard = [
                    [InlineKeyboardButton("🍔 Food", callback_data="category_food"),
                    InlineKeyboardButton("🚗 Transport", callback_data="category_transport")],
                    [InlineKeyboardButton("🎬 Entertainment", callback_data="category_entertainment"),
                    InlineKeyboardButton("🛍 Shopping", callback_data="category_shopping")],
                    [InlineKeyboardButton("📱 Subscriptions", callback_data="category_subscriptions"),
                    InlineKeyboardButton("💊 Health", callback_data="category_health")],
                    [InlineKeyboardButton("🏠 Housing", callback_data="category_housing"),
                    InlineKeyboardButton("📦 Other", callback_data="category_other_spend")]
                ]
                user_transactions_page_cache.pop(telegram_id,None)
                await update.message.reply_text(
                    f"💸 What kind of spending was that? Pick a category below!",
                    reply_markup=InlineKeyboardMarkup(keyboard)
                )
                return
            else :
                await update.message.reply_text(
                    "⚠️ Just reply with the number of your selection.",
                    parse_mode="Markdown"
                )
            return

    # --- Handle Get ---
    if pending_transactions[telegram_id].get('type') == 'income':
        step = pending_transactions[telegram_id].get("step")
        if step == 'input_amount':
            
            match = re.match(r'^(\d+)(?:\s+(.+))?$', text)
            if not match:
                await update.message.reply_text("💡 Please start your message with a number, like:\n"
                                                "`10000 Interest`\n"
                                                "The amount comes first, followed by an optional description.", parse_mode="Markdown")
                return
            
            amount = match.group(1)
            item = match.group(2) if match.group(2) else ""
            msg_date = update.message.date.astimezone(pytz.timezone("Asia/Jakarta"))
            date_str = msg_date.strftime('%d %b %Y %H:%M')

            pending_transactions[telegram_id]['data'].update({
                "user_id": user_id,
                "amount": float(amount),
                "item": (item),  
                "type": "get",
                "date": msg_date,
            })
            
            res = supabase.table("savings_accounts") \
                            .select("id,account_name,account_number") \
                            .eq("user_id", user_id) \
                            .order("priority", desc=False) \
                            .order("account_name", desc=False) \
                            .execute()
                
            txs = res.data or []
            user_transactions_page_cache[telegram_id] = txs
            if not txs:
                text ="💡 It looks like you haven’t created a savings account yet.\n" \
                        "You can create one now by using:\n" \
                        "/add_saving"
                pending_transactions.pop(telegram_id,None)
            
            else :
                text_line = [f"🏦 Great! Let’s pick a savings account to continue:\n\n"]
                for i, tx in enumerate(txs, start=1):
                    text_line.append(
                    f"*{i}.* {tx['account_name'].upper()} (•••{tx['account_number'][-4:]})\n"
                    )
                text = "".join(text_line) + "\n💬 Please _reply_ with the number of the savings account you want to use."
                pending_transactions[telegram_id]["step"] = "select_saving"
            await update.message.reply_text(text,parse_mode="Markdown")
            return

        
        if step == 'select_saving':
            if text.isdigit():
                txs = user_transactions_page_cache.get(telegram_id)
                index = int(text) - 1
                if not txs or index >= len(txs):
                    await update.message.reply_text("⚠️ Invalid selection.")
                    return
                
                tx = txs[index]
                pending_transactions[telegram_id]["data"].update({
                "saving_id" : int(tx['id']),
                "saving_name" : f"{tx['account_name']} (•••{tx['account_number'][-4:]})"
                })
                
                
                keyboard = [
                    [InlineKeyboardButton("💼 Salary", callback_data="category_salary"),
                    InlineKeyboardButton("🧾 Freelance", callback_data="category_freelance")],
                    [InlineKeyboardButton("🎁 Gift", callback_data="category_gift"),
                    InlineKeyboardButton("📈 Investment", callback_data="category_investment")],
                    [InlineKeyboardButton("💸 Refund", callback_data="category_refund"),
                    InlineKeyboardButton("📦 Other", callback_data="category_other_get")]
                ]

                await update.message.reply_text(
                    f"💰 What kind of income was that? Pick a category!",
                    reply_markup=InlineKeyboardMarkup(keyboard)
                )
                return 
            
            else :
                await update.message.reply_text(
                    "⚠️ Just reply with the number of your selection.",
                    parse_mode="Markdown"
                )
            return
    
    # --- Delete Mode (reply with number) ---
    if pending_transactions[telegram_id].get('type') == 'manage_tx':
        step = pending_transactions[telegram_id].get("step")
        if step == 'choose_transaction':
            if text.isdigit():
                index = int(text) - 1
                txs = user_transactions_page_cache.get(telegram_id)

                if not txs or index >= len(txs):
                    await update.message.reply_text("⚠️ Invalid selection.")
                    return

                tx = txs[index]

                # Cache it for confirmation
                pending_transactions[telegram_id]["data"] = tx
                if tx.get('saving_id') :
                    pending_transactions[telegram_id]["data"].update({
                        "savings_accounts" : f"{tx['savings_accounts'].get('account_name').upper()} (•••{tx['savings_accounts'].get('account_number')[-4:]})"
                    })
                else :
                    pending_transactions[telegram_id]["data"].update({
                        "savings_accounts" : "No Saving"
                    })
                
                # Format time
                t = datetime.fromisoformat(tx["date"]).astimezone(pytz.timezone("Asia/Jakarta"))
                date_str = t.strftime("%d %b %Y %H:%M:%S")
                type_icon = "💸" if tx["type"] == "spend" else "💰"
                # Ask for confirmation
                msg = [
                    f"🛠️ *Modify This Transaction ?*\n\n"
                    f"🧾 {date_str}\n"
                    f"📌 Type : {tx['type']}"
                ]
                
                if tx['item'] != '' :
                    msg.append(
                        f"📦 Item : {tx['item']}"
                    )
                    
                msg.append(
                    f"{type_icon} Amount : {abs(int(tx['amount']))}\n"
                    f"📂 Category : {tx.get('category', '-')}\n"
                    f"🏦 Saving : {tx['savings_accounts']}\n\n"
                )
                text = "\n".join(msg)
                
                keyboard = [
                    [
                        InlineKeyboardButton("✅ Yes", callback_data="confirm_manage_transaction_yes"),
                        InlineKeyboardButton("❌ No", callback_data="confirm_manage_transaction_no"),
                    ]
                ]

                await update.message.reply_text(
                    text,
                    parse_mode="Markdown",
                    reply_markup=InlineKeyboardMarkup(keyboard)
                )
                return
            else :
                await update.message.reply_text(
                    "⚠️ Just reply with the number of your selection.",
                    parse_mode="Markdown"
                )
                return
        if step == 'processing_trx':
            edit_type = pending_transactions[telegram_id].get("edit_type")
            if edit_type == 'amount':
                
                if text.isdigit():
                    if int(text) == abs(pending_transactions[telegram_id]["data"]["amount"]) :
                        await update.message.reply_text(
                            f"⚠️ No changes detected !!!\n\n_You entered {int(text)}, which is the same as before. Please provide a new amount._",
                            parse_mode="Markdown"
                        )
                        pending_transactions[telegram_id].update({
                        "edit_type" : ""
                        })
                        time.sleep(1.5)
                        await manage_edit(update,telegram_id)
                        return
                    else :
                        pending_transactions[telegram_id]["new_data"].update({
                            "amount" : int(text)
                        })
                        text = f"✅ Done! The amount has been updated."
                        await update.message.reply_text(
                            text,
                            parse_mode="Markdown"
                        )
                        pending_transactions[telegram_id].update({
                        "edit_type" : ""
                         })
                        time.sleep(1.5)
                        await manage_edit(update,telegram_id)
                    return
                else :
                    await update.message.reply_text(
                        "⚠️ Just reply with the right amount",
                        parse_mode="Markdown"
                    )
                    return
            elif edit_type == 'saving':
                if text.isdigit():
                    txs = user_transactions_page_cache.get(telegram_id)
                    
                    index = int(text) - 1
                    if not txs or index >= len(txs):
                        await update.message.reply_text("⚠️ Invalid selection.")
                        return
                    
                    tx = txs[index]
                    pending_transactions[telegram_id]["new_data"].update({
                            "saving_id" : int(tx['id']),
                            "savings_accounts" : f"{tx['account_name']} (•••{tx['account_number'][-4:]})"
                        })
                    
                    text = f"✅ Done! The saving has been updated."
                    await update.message.reply_text(
                        text,
                        parse_mode="Markdown"
                    )
                    pending_transactions[telegram_id].update({
                        "edit_type" : ""
                    })
                    time.sleep(1.5)
                    await manage_edit(update,telegram_id)
                else :
                    await update.message.reply_text(
                        "⚠️ Reply with the number of your saving account.",
                        parse_mode="Markdown"
                    )
                return
            
            elif edit_type == 'name':   
                if text.lower() == pending_transactions[telegram_id]["data"]["item"].lower():
                    await update.message.reply_text(
                        f"⚠️ No changes detected !!!\n\n_You entered {text}, which is the same as before. Please provide a new name._",
                        parse_mode="Markdown"
                    )
                    pending_transactions[telegram_id].update({
                        "edit_type" : ""
                    })
                    time.sleep(1.5)
                    await manage_edit(update,telegram_id)
                    return 
                pending_transactions[telegram_id]["new_data"].update({
                            "item" : text,
                })
                text = f"✅ Done! The name has been updated."
                await update.message.reply_text(
                    text,
                    parse_mode="Markdown"
                )
                pending_transactions[telegram_id].update({
                        "edit_type" : ""
                    })
                time.sleep(1.5)
                await manage_edit(update,telegram_id)
                return
                
    if pending_transactions[telegram_id].get('type') == "manage_sv":
        step = pending_transactions[telegram_id].get("step")
        if step == 'selecting_saving' :
            if text.isdigit():
                            
                txs = user_transactions_page_cache.get(telegram_id)
                
                index = int(text) - 1
                if not txs or index >= len(txs):
                    await update.message.reply_text("⚠️ Invalid selection.")
                    return
                
                pending_transactions[telegram_id]["data"] = txs[index]
                
                text = f"✨ What would you like to do with this saving?\n\n" \
               f"_Please choose how you'd like to manage it._"    
                keyboard = [
                        [InlineKeyboardButton("✏️ Edit", callback_data="manage_sv_type_edit")],
                        [InlineKeyboardButton("🗑️ Delete", callback_data="manage_sv_type_delete")]
                ]
                
                await update.message.reply_text(
                    text,
                    parse_mode="Markdown",
                    reply_markup=InlineKeyboardMarkup(keyboard)
                )
                return
            else :
                await update.message.reply_text(
                    "⚠️ Just reply with the number of your selection.",
                    parse_mode="Markdown"
                )
                return
    
    if pending_transactions[telegram_id].get('type') == 'config':
        step = pending_transactions[telegram_id].get("step")  
        if step == 'enter_password':
            if str(text) != REGISTER_PASSWORD :
                await update.message.reply_text("🚫 Access Denied – Wrong access code")
                return
            else :
                pending_transactions[telegram_id].update({
                    "step" : 'select_update'
                })
                await selecting_config(update,context)
                return
        if step == 'link_update':
            SUPABASE_URL_temp = str(text)
            supabase_temp = create_client(SUPABASE_URL_temp, SUPABASE_KEY)
            try :
                result = supabase_temp.table("user").select("id").eq("telegram_id", telegram_id).execute()
                SUPABASE_URL = SUPABASE_URL_temp
                supabase  = create_client(SUPABASE_URL, SUPABASE_KEY)
                await update.message.reply_text("🎉 Update successful! Connection is now established.")
            except :
                await update.message.reply_text("❌ Connection failed. Update was not applied.")
            time.sleep(1.5)
            await selecting_config(update,context) 
            return
        elif step == 'link_key':
     
            SUPABASE_KEY_temp = str(text)
            supabase_temp = create_client(SUPABASE_URL, SUPABASE_KEY_temp)
            try :
                result = supabase_temp.table("user").select("id").eq("telegram_id", telegram_id).execute()
                SUPABASE_KEY = SUPABASE_KEY_temp
                supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
                await update.message.reply_text("🎉 Update successful! Connection is now established.")
            except :
                await update.message.reply_text("❌ Connection failed. Update was not applied.")
            time.sleep(1.5)
            await selecting_config(update,context) 
            return
        
        elif step == 'access':
           
            REGISTER_PASSWORD = str(text)
            res = supabase.table("user") \
                    .select("access_key") \
                    .eq("id", user_id) \
                    .execute()
            
            key = res.data  
                 
            if str(text) == key[0]['access_key']:
                await update.message.reply_text(f"😥 Update failed! Access Key cannot be same !!!",message_effect_id=FAIL_EFFECT_IDS["poo"])
            
            else :
                pending_transactions[telegram_id].update({
                    "new_password" : str(text)
                })
                try :
                    # supabase.table('user').update({'access_key': str(text)}).eq('id', user_id).execute()
                    await update.message.reply_text("🎉 Update successful!",message_effect_id=SUCCESS_EFFECT_IDS['party'])

                except:
                    await update.message.reply_text(f"😥 Update failed!",message_effect_id=FAIL_EFFECT_IDS["poo"])
                
            time.sleep(1.5)
            await selecting_config(update,context) 
            return
        
    if pending_transactions[telegram_id].get('type') == 'tranfer':
        step = pending_transactions[telegram_id].get("step")  
        if step == 'select_source':
            if text.isdigit():
                svs = user_transactions_page_cache.get(telegram_id)
                
                index = int(text) - 1
                if not svs or index >= len(svs):
                    await update.message.reply_text("⚠️ Invalid selection.")
                    return
                
                sv = svs[index]
                
                if sv['balance'] <= 0 :
                    await update.message.reply_text("💡 Looks like this account is empty right now.")
                    time.sleep(1.5)
                    await transfer(update,context)
                    return
                
                pending_transactions[telegram_id]['data_source'] = sv
                pending_transactions[telegram_id].update({
                    'step' : 'select_destination'
                })
                user_transactions_page_cache.pop(telegram_id,None)
                
                
                res = supabase.table("savings_accounts") \
                    .select("id, account_name, account_number,print_name,balance") \
                    .eq("user_id", user_id) \
                    .neq("id",sv['id']) \
                    .execute()
                
                svs =  res.data or []
                user_transactions_page_cache[telegram_id] = svs
                
                if not svs :
                    await update.message.reply_text("💡 It looks like you only created a single savings account.\n\n" \
                                    "You can create another saving by using:\n" \
                                    "/add_saving") 
                    return  

                msg = ["✨ *Where should we send the money ?*\n\nSelect your *destination* account below:\n\n"]
                        
                for i,sv in enumerate(svs,start=1):
                    balance = f"Rp. {int(sv['balance']):,}" if sv['balance'] > 0 else "No Balance"
                    msg.append(f"*{i}. {sv['print_name']}* - {balance}\n")
                   
                
                txt = ''.join(msg) + "\n👉 Reply with the number of the account you want.\nFor example, type 1 for the first account."
                await update.message.reply_text(txt,parse_mode="Markdown")
                return
                                
            else :
                            
                await update.message.reply_text(
                        "⚠️ Reply with the number of your saving account.",
                        parse_mode="Markdown"
                    )
                return
        if step == 'select_destination':
            if text.isdigit():
                svs = user_transactions_page_cache.get(telegram_id)
                
                index = int(text) - 1
                if not svs or index >= len(svs):
                    await update.message.reply_text("⚠️ Invalid selection.")
                    return
                
                sv = svs[index]
                
                pending_transactions[telegram_id]['data_dest'] = sv
                pending_transactions[telegram_id].update({
                    'step' : 'trf_nominal'
                })
                await update.message.reply_text('💸 How much would you like to transfer?',parse_mode="Markdown")
                
                return
            else :
                await update.message.reply_text(
                        "⚠️ Reply with the number of your saving account.",
                        parse_mode="Markdown"
                    )
                return
        
        if step == 'trf_nominal':
            if is_valid_float_nominal(text):
        
                amount = float(text)
                
                if amount > pending_transactions[telegram_id]['data_source']['balance'] :
                    await update.message.reply_text(
                        "⚠️ Insufficient funds in the source account.", parse_mode="Markdown")
                    return
                
                pending_transactions[telegram_id].update({
                    "amount" : amount
                })
                
                buttons = [            
                        [
                    InlineKeyboardButton("✅ Yes", callback_data="trf_yes"),
                    InlineKeyboardButton("❌ No", callback_data="trf_no"),
                        ]]
                markup = InlineKeyboardMarkup(buttons)
                
                source_balance_after = pending_transactions[telegram_id]['data_source']['balance'] - amount
                dest_balance_after  = pending_transactions[telegram_id]['data_dest']['balance'] + amount
                
                source_balance_before = f"Rp. {int(pending_transactions[telegram_id]['data_source']['balance']):,}"
                source_balance_after = f"Rp. {int(source_balance_after):,}" if source_balance_after > 0 else "No Balance"
               
                dest_balance_before = f"Rp. {int(pending_transactions[telegram_id]['data_dest']['balance']):,}"  if pending_transactions[telegram_id]['data_dest']['balance'] > 0 else "No Balance"
                dest_balance_after = f"Rp. {int(dest_balance_after):,}" 
                
                msg = "🚀 Ready to Transfer?\n\n" \
                    f"Amount: Rp {amount:,}\n\n" \
                    f"From: {pending_transactions[telegram_id]['data_source']['print_name']})\n" \
                    f"💰 {source_balance_before} → {source_balance_after}\n\n" \
                    f"To: {pending_transactions[telegram_id]['data_dest']['print_name']})\n" \
                    f"💰 {dest_balance_before} → {dest_balance_after}\n\n" \
                    f"💸 Are you sure you want to proceed with this transfer?"
                    
                await update.message.reply_text(msg,reply_markup=markup, parse_mode="Markdown")
                return
                

            else :
                await update.message.reply_text(
                        "⚠️ Oops! Please enter a valid amount to transfer.",
                        parse_mode="Markdown"
                    )
                return
            
    if pending_transactions[telegram_id].get('type') == 'add_bill':
        step = pending_transactions[telegram_id].get("step")  
        if step == 'amount':
            if is_valid_float_nominal(text):
                
                pending_transactions[telegram_id]["data"].update({
                    "amount" : float(text)
                })
                
                pending_transactions[telegram_id]["step"] = "saving"
                
                res = supabase.table("savings_accounts") \
                    .select("id,print_name,balance") \
                    .eq("user_id", user_id) \
                    .eq("saving_type","credit") \
                    .execute()
                
                svs =  res.data or []
                user_transactions_page_cache[telegram_id] = svs
                
                if not svs :
                    txt = "💡 It looks like you haven’t created a credit savings account yet.\n\n" \
                                    "You can create one now by using:\n" \
                                    "/add_saving"
                                    
                else :
                    msg = ["✨ *Let’s get started!*\n\nSelect your credit account below:\n\n"]
                    
                    for i,sv in enumerate(svs,start=1):
                        balance = f"Rp. {int(sv['balance']):,}" if sv['balance'] > 0 else "No outstanding balance"
                        msg.append(f"*{i}. {sv['print_name']}* - {balance}\n")
                        
                    msg.append(f"*{len(svs)+1}. None*\n")
                     
                    txt = ''.join(msg) + "\n👉 Reply with the number of the account you want.\nFor example, type 1 for the first account."
                    
                    
                await update.message.reply_text(
                        txt,
                        parse_mode="Markdown"
                )
                return
            else :
                await update.message.reply_text(
                        "⚠️ Oops! Please enter a valid amount.",
                        parse_mode="Markdown"
                )
                return
            
        if step == 'saving':
            if text.isdigit():
                
                index = int(text) - 1
                svs = user_transactions_page_cache[telegram_id]
                
                if not svs or index > len(svs):
                    await update.message.reply_text("⚠️ Invalid selection.")
                
                if index == len(svs):
                    pending_transactions[telegram_id]["data_saving"] = None
                else :
                    pending_transactions[telegram_id]["data_saving"] = svs[index]
                
            else :
                await update.message.reply_text(
                        "⚠️ Reply with the number of your saving account.",
                        parse_mode="Markdown"
                    )
    await update.message.reply_text("🤖 Sorry, I didn’t understand that. Please use a command like /spend, /get, or /history.")
    return

async def run_scheduler(application):
    if not scheduler.running:
        print("📅 Starting Scheduler ...")
        os.system('cls' if os.name == 'nt' else 'clear')
        scheduler.add_job(notify_upcoming_bills, 'cron', hour=7, minute=0, id='daily_billing')
        scheduler.start()
        print("😊 Bot and Scheduler are ready to used")

app = ApplicationBuilder().token(BOT_TOKEN).post_init(run_scheduler).build()

# handle command
app.add_handler(CommandHandler("start", start))
app.add_handler(CommandHandler("register", register))
app.add_handler(CommandHandler("add_sv", add_saving))
app.add_handler(CommandHandler("get", get_income))
app.add_handler(CommandHandler("spend", spend))
app.add_handler(CommandHandler("mod_tx", manage_transaction_command))
app.add_handler(CommandHandler("mod_sv", manage_saving_command))
app.add_handler(CommandHandler("config", config))
app.add_handler(CommandHandler("transfer",transfer))
app.add_handler(CommandHandler("add_bill",add_bill))
# app.add_handler(CommandHandler("history", history))
# app.add_handler(CommandHandler("info", info))

# handle text
app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_text_input))

# handle button
app.add_handler(CallbackQueryHandler(handle_interest_button, pattern=r"^interest_"))
app.add_handler(CallbackQueryHandler(category_callback, pattern=r"^category_"))
app.add_handler(CallbackQueryHandler(delete_pagination_callback, pattern="^delete_"))
app.add_handler(CallbackQueryHandler(handle_saving_confirmation_button, pattern=r"^confirm_saving_"))
app.add_handler(CallbackQueryHandler(confirm_get_callback, pattern=r"^confirm_income_"))
app.add_handler(CallbackQueryHandler(confirm_spend_callback, pattern=r"^confirm_outcome_"))
app.add_handler(CallbackQueryHandler(confirm_manage_transaction_callback, pattern=r"^confirm_manage_transaction_"))
app.add_handler(CallbackQueryHandler(manage_type_callback, pattern=r"^manage_type_"))
app.add_handler(CallbackQueryHandler(manage_sv_type_callback, pattern=r"^manage_sv_type_"))
app.add_handler(CallbackQueryHandler(confirm_delete_sv_callback, pattern=r"^confirm_delete_sv_"))
app.add_handler(CallbackQueryHandler(confirm_delete_callback, pattern=r"^confirm_delete_"))
app.add_handler(CallbackQueryHandler(confirm_edit_sv_callback, pattern=r"^edit_sv"))
app.add_handler(CallbackQueryHandler(confirm_edit_callback, pattern=r"^edit_"))
app.add_handler(CallbackQueryHandler(config_callback, pattern=r"^config_"))
app.add_handler(CallbackQueryHandler(confirm_tranfer_callback, pattern=r"^trf_"))



def main():
    print("🤖 starting Bot ...")
    app.run_polling()
    
     

if __name__ == "__main__":
    main()