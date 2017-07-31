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
      v: 0.5, // volume
      V: 0, // decayed volume at end of note
      f: 1, // low-pass filter frequency in kHz
      F: 0.1, // decayed low-pass filter frequency in kHz
      M: 14, // muted after this many loops
      g: 1, // glide notes to this frequency in Hz (useful for kicks drums)

      // notes, -1 = off note
      n: [
        40,,,36,,,-1,,
      ],
    },

    // Chip bass pattern 1
    {
      t: 'square', // oscillator type
      v: 0.2, // volume
      V: 0, // decayed volume at end of note
      f: 14, // low-pass filter frequency in kHz
      F: 5, // decayed low-pass filter frequency in kHz
      M: 10, // muted after this many loops
      m: 4, // muted for this many loops
      d: .35, // slapback delay echo volume
      r: 16, // rate divisor
      A: 1, // arp speed

      // notes, -1 = off note
      n: [
        [24,-1,,], // A4
        [27,-1,,], // C5
        [20,-1,,], // F4
        [22,-1,,], // G4
      ],
    },

    // Chip melody pattern 1
    {
      t: 'square', // oscillator type
      v: 0.1, // volume
      V: 0, // decayed volume at end of note
      f: 8, // low-pass filter frequency in kHz
      F: 0, // decayed low-pass filter frequency in kHz
      M: 8, // muted after this many loops
      m: 6, // muted for this many loops
      d: .6, // slapback delay echo volume
      r: 16, // rate divisor
      A: 1/3, // arp speed

      // notes, -1 = off note
      n: [
        [55,51,58,60,63,60],
        [55,58,60,62,60,58],
        [51,53,58,60,58],
        [58,53,62,58,62,60],
      ],
    },

    // Chip melody pattern 2
    {
      t: 'square', // oscillator type
      v: 0.1, // volume
      V: 0, // decayed volume at end of note
      f: 4, // low-pass filter frequency in kHz
      F: 0, // decayed low-pass filter frequency in kHz
      M: 10, // muted after this many loops
      m: 8, // muted for this many loops
      d: .5, // slapback delay echo volume
      r: 16, // rate divisor
      A: 1, // arp speed

      // notes, -1 = off note
      n: [
        [67, 63, 60],
        [62, 58, 55],
        [63, 60, 56],
        [65, 62, 58]
      ],
    },

    // Chip melody pattern 3
    {
      t: 'square', // oscillator type
      v: 0.1, // volume
      V: 0.1, // decayed volume at end of note
      f: 4, // low-pass filter frequency in kHz
      F: 0, // decayed low-pass filter frequency in kHz
      M: 12, // muted after this many loops
      m: 10, // muted for this many loops
      d: .5, // slapback delay echo volume
      r: 16, // rate divisor
      A: 0.5, // arp speed

      // notes, -1 = off note
      n: [
        [48,43],
        [51,46],
        [44,39],
        [43,38]
      ],
    },

    // Choir pattern 1
    {
      t: 'square', // oscillator type
      v: 0.1, // volume
      V: 0 , // decayed volume at end of note
      f: 6, // low-pass filter frequency in kHz
      F: 0, // decayed low-pass filter frequency in kHz
      m: 2, // muted for this many loops
      M: 4, // muted after this many loops
      d: 0.4,
      r: 8, // rate divisor

      // notes, -1 = off note
      n: [
        48,48, // A6
        46,46, // G6
        51,51, // C7
        50,46, // B6
      ],
    },
  ].concat(
    // Snare: multiple layered square waves produce noise
    Array(6).fill().map((e, i) => ({
      t: 'square', T: 'highpass', V: 0, f: 5,

      n: [,,31 + i,-1,],

      F: 10, M: 10, m: 4, v: 0.3, r: 2
    }))
  ).concat(
    // Hi-hat 2: multiple layered square waves produce noise
    Array(6).fill().map((e, i) => ({
      t: 'square', T: 'highpass', V: 0, f: 5,

      n: [,,31 + i,-1,],

      F: 10, M: 10, m: 2, v: 0.5
    }))
  ).concat(
    // Hi-hat 1: multiple layered square waves produce noise
    Array(6).fill().map((e, i) => ({
      t: 'square', T: 'highpass', V: 0, f: 5,

      n: [31 + i],

      F: 17, M: 11, m: 0, v: 0.3, 
    }))
  )
};
