s = {
  b: .15, // seconds per row: (BPM / 60) / (rows per beat)
  r: 128,  // rows per loop
  l: 16,  // loops

  // Instruments
  i: [
    // Kick drum
    {
      // oscillator is sine by default
      //t: 'sine', // oscillator type
      a: 0.02, // attack time
      v: 0.5, // volume
      V: 0, // decayed volume at end of note
      f: 1, // low-pass filter frequency in kHz
      F: 0.1, // decayed low-pass filter frequency in kHz
      //m: 0, // muted for this many loops
      M: 7, // muted after this many loops
      g: 1, // glide notes to this frequency in Hz (useful for kicks drums)

      // notes, -1 = off note
      n: [
        40,,,36,,,-1,,
      ],
    },

    // Snare
    {
      t: 'square', // oscillator type
      a: 0.01, // attack time
      v: 0.3, // volume
      V: 0, // decayed volume at end of note
      f: 10, // low-pass filter frequency in kHz
      F: 10, // decayed low-pass filter frequency in kHz
      M: 5, // muted after this many loops
      g: 10, // glide notes to this frequency in Hz (useful for kicks drums)

      // notes, -1 = off note
      n: [
        ,,,,42,,-1,,
      ],
      m: 1, // muted for this many loops
    },

    // Hi-hat: multiple layered square waves produce noise
    {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 17, m: 4, M: 4,
      n: [31],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 17, m: 4, M: 4,
      n: [32],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 17, m: 4, M: 4,
      n: [33],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 17, m: 4, M: 4,
      n: [34],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 17, m: 4, M: 4,
      n: [35],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 17, m: 4, M: 4,
      n: [36],
    },

    // Bass 1
    {
      t: 'square', // oscillator type
      a: 0.02, // attack time
      v: 0.1, // volume
      V: 0.1, // decayed volume at end of note
      f: 4, // low-pass filter frequency in kHz
      F: 4, // decayed low-pass filter frequency in kHz
      M: 5, // muted after this many loops
      m: 0, // muted for this many loops

      // notes, -1 = off note
      n: [
        24,-1,,24,-1,,24,-1,,24,-1,,24,-1,,, // A4
        27,-1,,27,-1,,27,-1,,27,-1,,27,-1,,, // C5
        20,-1,,20,-1,,20,-1,,20,-1,,20,-1,,, // F4
        19,-1,,19,-1,,19,-1,,,19,-1,19,-1,,, // E4
      ],
    },

    // // Lead
    // {
    //   t: 'square', // oscillator type
    //   a: 0.01, // attack time
    //   v: 0.2, // volume
    //   V: 0.01, // decayed volume at end of note
    //   f: 10, // low-pass filter frequency in kHz
    //   F: 1, // decayed low-pass filter frequency in kHz
    //   m: 3, // muted for this many loops
    //   M: 6, // muted after this many loops
    //
    //   // notes, -1 = off note
    //   n: [
    //     36,, 31,, 36,, 31,, 36,, 31,, 36,, 31,,
    //     39,, 34,, 39,, 34,, 39,, 34,, 39,, 34,,
    //     32,, 27,, 32,, 27,, 32,, 27,, 32,, 27,,
    //     31,, 26,, 31,, 26,, 31,, 26,, 31,, 26,,
    //
    //     36,, 31,, 36,, 31,, 36,, 31,, 36,, 31,,
    //     39,, 34,, 39,, 34,, 39,, 34,, 39,, 34,,
    //     34,, 27,, 34,, 27,, 34,, 27,, 34,, 27,,
    //     32,, 29,, 32,, 29,, 32,, 29,, 32,, 29,,
    //   ],
    // },

    // Choir
    {
      t: 'sine', // oscillator type
      a: 0.1, // attack time
      v: 0.1, // volume
      V: 0.1, // decayed volume at end of note
      f: 1, // low-pass filter frequency in kHz
      F: 1, // decayed low-pass filter frequency in kHz
      m: 0, // muted for this many loops
      M: 6, // muted after this many loops

      // notes, -1 = off note
      n: [
        48,,,,,,,,,,,,,,,, // A6
        46,,,,,,,,,,,,,,,, // G6
        51,,,,,,,,,,,,,,,, // C7
        50,,,,,,,,,,,,,,,, // B6
      ],
    }
  ]
};
