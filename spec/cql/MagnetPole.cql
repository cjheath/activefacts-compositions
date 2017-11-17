// This example shows identification of an entity by two roles, one binary, one unary
vocabulary MagnetPole;

each Magnet [separate] is identified by its AutoCounter;

each MagnetPole is identified by Magnet and MagnetPole is north where
    that MagnetPole belongs to one Magnet,
    that MagnetPole is north;
