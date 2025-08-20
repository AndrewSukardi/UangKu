from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import BaseDocTemplate, Frame, PageTemplate, Table, TableStyle, Spacer, Paragraph
from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle

red_5 = colors.HexColor("#B71C1C")
red_4 = colors.HexColor("#D32F2F")
red_3 = colors.HexColor("#EF5350")
red_2 = colors.HexColor("#E57373")
red_1 = colors.HexColor("#F9EBEB")
dark_grey = colors.HexColor("#333333")
light_grey = colors.HexColor("#f2f2f2")
medium_grey = colors.HexColor("#666666")

def draw_header(c, doc, user_name, account_number, balance):
    width, height = letter
    dark_grey = colors.HexColor("#333333")
    medium_grey = colors.HexColor("#666666")
    light_grey = colors.HexColor("#f2f2f2")

    # # Header - Bank Name
    # c.setFillColor(dark_grey)
    # c.setFont("Helvetica-Bold", 24)
    # c.drawString(50, height - 50, "UangKu")

    # # Bank info
    # c.setFont("Helvetica", 10)
    # c.setFillColor(medium_grey)
    # c.drawString(50, height - 70, "123 Finance Street, Money City, Country")
    # c.drawString(50, height - 85, "Phone: +1 234 567 890 | Email: support@mybank.com")

    # # Statement title box
    # box_x, box_y = 45, height - 100
    # box_width, box_height = width - 90, 45
    # c.setFillColor(red_3)
    # c.roundRect(box_x, box_y, box_width, box_height, 5, fill=1, stroke=0)

    # Statement title text
    c.setFillColor(dark_grey)
    c.setFont("Helvetica-Bold", 18)
    c.drawCentredString(width / 2, height - 50, "Monthly E-Statement")

    # Account details
    c.setFont("Helvetica", 11)
    c.setFillColor(dark_grey)
    c.drawString(50, height - 120, f"Account Holder: {user_name}")
    c.drawString(50, height - 140, f"Account Number: {account_number}")

    # Current balance box
    bal_box_x, bal_box_y = width - 210, height - 125
    bal_box_width, bal_box_height = 160, 45
    c.setFillColor(colors.white)
    c.roundRect(bal_box_x, bal_box_y, bal_box_width, bal_box_height, 5, fill=1, stroke=1)

    # Balance text inside box
    c.setFillColor(medium_grey)
    c.setFont("Helvetica-Bold", 10)
    c.drawString(bal_box_x + 10, height - 96, "Total Balance:")
    c.setFillColor(dark_grey)
    c.setFont("Helvetica-Bold", 14)
    c.drawString(bal_box_x + 10, height - 116, f"${balance:,.2f}")

    # Divider line
    c.setStrokeColor(medium_grey)
    c.setLineWidth(1)
    c.line(45, height - 155, width - 45, height - 155)

    # Optional page number
    c.setFont("Helvetica-Oblique", 9)
    c.setFillColor(medium_grey)
    c.drawRightString(width - 50, height - 30, f"Page {doc.page}")
    
    # Footer
    c.setFont("Helvetica-Oblique", 9)
    c.setFillColor(medium_grey)
    c.drawString(50, 28, "This is a computer-generated statement and does not require a signature.")

def generate_estatement_with_header(filename, user_name, account_number, transactions, balance):
    width, height = letter

    doc = BaseDocTemplate(filename, pagesize=letter,
                          leftMargin=50, rightMargin=50,
                          topMargin=160, bottomMargin=50)

    # Frame defines where the flowables (body content) will be drawn, leaving space for header
    frame = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id='normal')

    # Page template with onPage callback to draw header on each page
    template = PageTemplate(id='test', frames=frame,
                            onPage=lambda c, d: draw_header(c, d, user_name, account_number, balance))

    doc.addPageTemplates([template])

    styles = getSampleStyleSheet()
    story = []

      # ───── Title (centered, bold) ─────
    title_style = ParagraphStyle(
        name="StatementTitle",
        parent=styles["Heading1"],
        alignment=1,  # Center
        fontSize=16,
        fontName="Helvetica-Bold",
        textColor=colors.HexColor("#333333"),
        spaceAfter=10
    )
    title = Paragraph("Transaction History", title_style)
    story.append(title)
    # Prepare table data
    data = [["Date", "Description", "Amount (USD)"]]
    for txn in transactions:
        date, desc, amount = txn
        data.append([date, desc, f"${amount:,.2f}"])

    # Minimalist table style
    


    
    style = TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), red_2),            # White header background
        ('TEXTCOLOR', (0, 0), (-1, 0), light_grey),                # Dark header text
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),          # Bold header font
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),

        # Horizontal line below header row
        ('LINEBELOW', (0, 0), (-1, 0), 1, colors.lightgrey),
    ])

    for i in range(1, len(data)):
        bg = red_1 if i % 2 == 0 else colors.white
        style.add('BACKGROUND', (0, i), (-1, i), bg)

    table = Table(data, colWidths=[1.5*inch, 4*inch, 1.5*inch])
    table.setStyle(style)

    story.append(table)

    doc.build(story)

    print(f"PDF saved as {filename}")

# Example usage
transactions = [
    ("2025-08-01", "Salary Deposit", 2500.00),
    ("2025-08-10", "ATM Withdrawal", -200.00),
    ("2025-08-15", "Online Transfer to Savings", -500.00),
    ("2025-08-20", "Utility Bill Payment", -150.75),
] * 20  # enough rows to force multiple pages

generate_estatement_with_header("estatement_with_header.pdf", "John Doe", "1234567890", transactions, 1649.25)
