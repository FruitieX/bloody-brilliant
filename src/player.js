/*
 * Copyright 2017 Rasmus Eskola
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

A = new AudioContext;

// Init instruments
I = s.i.map(i => {
  o = A.createOscillator();
  e = A.createGain();
  l = A.createBiquadFilter();

  // Set oscillator type
  o.type = i.t;

  // Start oscillator
  o.start();

  // Oscillators start out silent, TODO: unnecessary?
  e.gain.value = 0;

  // Set filter Q value
  //l.Q.value = 12;

  l.type = i.T;

  // Connect oscillator to envelope
  o.connect(e);

  // Connect envelope to filter
  e.connect(l);

  // Connect filter to master out
  l.connect(A.destination);

  // TODO: object spread not supported by uglifyes, babili?
  // TODO: something in the build chain expands object shorthand syntax
  // ex. { e } => { e: e }
  // NOTE: at the moment we do awful things (find and replace) to save
  // some space
  return Object.assign({ o, e, l }, i);
});

// Program notes
for (l = s.l - 1; l > -1; l--) { // loop repetitions (in reverse order)
  for (r = s.r - 1; r > -1; r--) { // rows (in reverse order)
    I.map(i => { // for each instrument
      N = i.n[r % i.n.length];

      // Instrument was just muted: insert off note
      if (!r && i.M == l - 1) N = -1;
      else if (
        // Otherwise don't do anything once instrument is muted
        i.m > l ||
        i.M < l ||
        // Or if note is undefined
        !N
      ) return;

      // ATTACK
      i.e.gain.setValueAtTime(
        // Note starts at silence
        0,

        // Start time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
      );
      i.e.gain.linearRampToValueAtTime(
        // Fade to full volume after attack, unless this is an off note
        N == -1 ? 0 : i.v,

        // Start time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
        + i.a       // Instrument attack
      );
      i.e.gain.setValueAtTime(
        // Full volume after attack, unless this is an off note
        N == -1 ? 0 : i.v,

        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
        + i.a       // Instrument attack
      );

      // LOW-PASS FILTER FREQUENCY
      i.l.frequency.setValueAtTime(
        i.f * 1000,

        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
      );

      // OSCILLATOR FREQUENCY
      i.o.frequency.setValueAtTime(
        440 * Math.pow(2, (N - 48) / 12),

        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
      );

      // DECAY
      if (!r && !l) return; // Only if this is not the first note
      i.e.gain.linearRampToValueAtTime(
        // Volume right before next note
        i.V,

        // End time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
        - 1e-3      // - delta
      );
      i.l.frequency.linearRampToValueAtTime(
        // Low-pass filter frequency right before next note
        i.F * 1000,

        // End time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
        - 1e-3      // - delta
      );

      if (!i.g) return; // Only glide notes if glide enabled
      i.o.frequency.exponentialRampToValueAtTime(
        // Oscillator frequency right before next note
        i.g,

        // End time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
        - 1e-3      // - delta
      );
    });
  }
}
