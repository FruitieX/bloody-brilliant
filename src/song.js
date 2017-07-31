// TODO: remove in production
// Offset start pattern with this many loops
//D = 6;

s = {
  b: .15, // seconds per row: (BPM / 60) / (rows per beat)
  r: 64,  // rows per loop
  l: 16,  // loops

  // Instruments
  i: [
    // Kick drum
    {
      // oscillator is sine by default
      //t: 'sine', // oscillator type
      v: .5, // volume
      V: 0, // decayed volume at end of note
      f: 1, // low-pass filter frequency in kHz
      F: .1, // decayed low-pass filter frequency in kHz
      M: 14, // muted after this many loops
      g: 1, // glide notes to this frequency in Hz (useful for kicks drums)
      N: 14, // transpose notes down by this much

      // notes, -1 = off note
      n: [
        5,,,1,,,-1,,
      ],
    },

    // Chip bass pattern 1
    {
      t: 'square', // oscillator type
      v: .2, // volume
      V: 0, // decayed volume at end of note
      f: 14, // low-pass filter frequency in kHz
      F: 5, // decayed low-pass filter frequency in kHz
      M: 10, // muted after this many loops
      m: 4, // muted for this many loops
      d: .4, // slapback delay echo volume
      r: 16, // rate divisor
      A: 1, // arp speed
      N: 29, // transpose notes down by this much

      // notes, -1 = off note
      n: [
        [5,-1,,], // A4
        [8,-1,,], // C5
        [1,-1,,], // F4
        [3,-1,,], // G4
      ],
    },

    // Chip melody pattern 1
    {
      t: 'square', // oscillator type
      v: .1, // volume
      V: 0, // decayed volume at end of note
      f: 8, // low-pass filter frequency in kHz
      F: 0, // decayed low-pass filter frequency in kHz
      M: 8, // muted after this many loops
      m: 6, // muted for this many loops
      d: .6, // slapback delay echo volume
      r: 16, // rate divisor
      A: 1/3, // arp speed
      N: -2, // transpose notes down by this much

      // notes, -1 = off note
      n: [
        [5,1,8,10,13,10],
        [5,8,10,12,10,8],
        [1,3,8,10,8],
        [8,3,12,8,12,10],
      ],
    },

    // Chip melody pattern 2
    {
      t: 'square', // oscillator type
      v: .1, // volume
      V: 0, // decayed volume at end of note
      f: 4, // low-pass filter frequency in kHz
      F: 0, // decayed low-pass filter frequency in kHz
      M: 10, // muted after this many loops
      m: 8, // muted for this many loops
      d: .5, // slapback delay echo volume
      r: 16, // rate divisor
      A: 1, // arp speed
      N: -6, // transpose notes down by this much

      // notes, -1 = off note
      n: [
        [13, 9, 6],
        [8, 4, 1],
        [9, 6, 2],
        [11, 8, 4]
      ],
    },

    // Chip melody pattern 3
    {
      t: 'square', // oscillator type
      v: .1, // volume
      V: .1, // decayed volume at end of note
      f: 4, // low-pass filter frequency in kHz
      F: 0, // decayed low-pass filter frequency in kHz
      M: 12, // muted after this many loops
      m: 10, // muted for this many loops
      d: .5, // slapback delay echo volume
      r: 16, // rate divisor
      A: .5, // arp speed
      N: 11, // transpose notes down by this much

      // notes, -1 = off note
      n: [
        [11,6],
        [14,9],
        [7,2],
        [6,1]
      ],
    },

    // Choir pattern 1
    {
      t: 'square', // oscillator type
      v: .1, // volume
      V: 0 , // decayed volume at end of note
      f: 6, // low-pass filter frequency in kHz
      F: 0, // decayed low-pass filter frequency in kHz
      m: 2, // muted for this many loops
      M: 4, // muted after this many loops
      d: .4,
      r: 8, // rate divisor
      N: 3, // transpose notes down by this much

      // notes, -1 = off note
      n: [
        3,3, // A6
        1,1, // G6
        6,6, // C7
        5,1, // B6
      ],
    },
  ].concat(
    // Snare: multiple layered square waves produce noise
    Array(6).fill().map((e, i) => ({
      t: 'square', T: 'highpass', V: 0, f: 5, N: 30,

      n: [,,1 + i,-1,],

      F: 10, M: 10, m: 4, v: 0.3, r: 2
    }))
  ).concat(
    // Hi-hat 2: multiple layered square waves produce noise
    Array(6).fill().map((e, i) => ({
      t: 'square', T: 'highpass', V: 0, f: 5, N: 30,

      n: [,,1 + i,-1,],

      F: 10, M: 10, m: 2, v: 0.5
    }))
  ).concat(
    // Hi-hat 1: multiple layered square waves produce noise
    Array(6).fill().map((e, i) => ({
      t: 'square', T: 'highpass', V: 0, f: 5, N: 30,

      n: [1 + i],

      F: 17, M: 11, m: 2, v: 0.3,
    }))
  )
};
