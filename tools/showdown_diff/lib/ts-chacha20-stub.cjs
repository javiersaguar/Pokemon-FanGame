// Sustituto de la dependencia 'ts-chacha20' de Pokémon Showdown.
// Showdown solo la usa para su generador "sodium"; el arnés le pasa su propio generador
// (el oráculo), así que nunca debería llegar a usarse.
class Chacha20 {
  constructor() {
    throw new Error('showdown_diff: ChaCha20 no está disponible; el arnés usa su propio generador.');
  }
}
module.exports = { Chacha20 };
