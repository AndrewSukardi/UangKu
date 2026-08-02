enum IconAssets {
  book('book.png'),
  box('box.png'),
  briefcase('briefcase.png'),
  budget('budget.png'),
  cart('cart.png'),
  clapperboard('clapperboard.png'),
  creditCard('credit-card.png'),
  failed('failed.png'),
  fitness('fitness.png'),
  food('food.png'),
  gift('gift.png'),
  handshake('handshake.png'),
  house('house.png'),
  increaseChart('increse-chart.png'),
  medicalBag('medical-bag.png'),
  money('money.png'),
  moneyBag('money-bag.png'),
  moneyHand('money-hand.png'),
  plane('plane.png'),
  success('success.png'),
  transaction('transaction.png'),
  transport('transport.png'),
  utilities('utilities.png');

  const IconAssets(this.fileName);

  final String fileName;

  static const String basePath = 'assets/icon/';

  String get path => '$basePath$fileName';
}
