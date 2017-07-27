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

    // Snare: multiple layered square waves produce noise
    {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 5, F: 9, m: 0, M: 4,
      n: [,,,,31,,-1,,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 5, F: 9, m: 0, M: 4,
      n: [,,,,32,,-1,,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 5, F: 9, m: 0, M: 4,
      n: [,,,,33,,-1,,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 5, F: 9, m: 0, M: 4,
      n: [,,,,34,,-1,,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 5, F: 9, m: 0, M: 4,
      n: [,,,,35,,-1,,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 5, F: 9, m: 0, M: 4,
      n: [,,,,36,,-1,,],
    },

    // Hi-hat 1: multiple layered square waves produce noise
    {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 8, F: 17, m: 0, M: 4,
      n: [31],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 8, F: 17, m: 0, M: 4,
      n: [32],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 8, F: 17, m: 0, M: 4,
      n: [33],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 8, F: 17, m: 0, M: 4,
      n: [34],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 8, F: 17, m: 0, M: 4,
      n: [35],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.3, V: 0, f: 8, F: 17, m: 0, M: 4,
      n: [36],
    },

    // Hi-hat 2: multiple layered square waves produce noise
    {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 10, m: 0, M: 4,
      n: [,,31,-1,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 10, m: 0, M: 4,
      n: [,,32,-1,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 10, m: 0, M: 4,
      n: [,,33,-1,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 10, m: 0, M: 4,
      n: [,,34,-1,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 10, m: 0, M: 4,
      n: [,,35,-1,],
    }, {
      t: 'square', T: 'highpass', a: 0.01, v: 0.5, V: 0, f: 5, F: 10, m: 0, M: 4,
      n: [,,36,-1,],
    },

    // Chip base pattern 1
    {
      t: 'square', // oscillator type
      a: 0.02, // attack time
      v: 0.1, // volume
      V: 0.1, // decayed volume at end of note
      f: 4, // low-pass filter frequency in kHz
      F: 4, // decayed low-pass filter frequency in kHz
      M: 2, // muted after this many loops
      m: 0, // muted for this many loops

      // notes, -1 = off note
      n: [
        24,-1,,24,-1,,24,-1,,24,-1,,24,-1,,, // A4
        27,-1,,27,-1,,27,-1,,27,-1,,27,-1,,, // C5
        20,-1,,20,-1,,20,-1,,20,-1,,20,-1,,, // F4
        19,-1,,19,-1,,19,-1,,,19,-1,19,-1,,, // E4
      ],
    },

    // Chip melody pattern 1
    {
      t: 'square', // oscillator type
      a: 0.02, // attack time
      v: 0.1, // volume
      V: 0.1, // decayed volume at end of note
      f: 4, // low-pass filter frequency in kHz
      F: 4, // decayed low-pass filter frequency in kHz
      M: 1, // muted after this many loops
      m: 0, // muted for this many loops

      // notes, -1 = off note
      n: [
        55,-1,,51,-1,,58,-1,,60,-1,,63,-1,60,-1,
        55,-1,,58,-1,,60,-1,,62,-1,,60,-1,58,-1,
        51,-1,,56,-1,,60,-1,,60,-1,,60,-1,62,-1,
        58,-1,,53,-1,,62,-1,,58,-1,,62,-1,60,-1,
      ],
    },

    // Chip melody pattern 2
    {
      t: 'square', // oscillator type
      a: 0.02, // attack time
      v: 0.1, // volume
      V: 0.1, // decayed volume at end of note
      f: 4, // low-pass filter frequency in kHz
      F: 4, // decayed low-pass filter frequency in kHz
      M: 1, // muted after this many loops
      m: 1, // muted for this many loops

      // notes, -1 = off note
      n: [
        67,63,60,67,63,60,67,63,60,67,63,60,67,63,60,67,
        62,58,55,62,58,55,62,58,55,62,58,55,62,58,55,62,
        63,60,56,63,60,56,63,60,56,63,60,56,63,60,56,63,
        65,62,58,65,62,58,65,62,58,65,62,58,65,62,58,65,
      ],
    },

    // Chip melody pattern 3
    {
      t: 'square', // oscillator type
      a: 0.02, // attack time
      v: 0.1, // volume
      V: 0.1, // decayed volume at end of note
      f: 4, // low-pass filter frequency in kHz
      F: 4, // decayed low-pass filter frequency in kHz
      M: 2, // muted after this many loops
      m: 2, // muted for this many loops

      // notes, -1 = off note
      n: [
        48,,43,,48,,43,,48,,43,,48,,43,,
        51,,46,,51,,46,,51,,46,,51,,46,,
        44,,39,,44,,39,,44,,39,,44,,39,,
        43,,38,,43,,38,,43,,38,,43,,38,,
      ],
    },

    // Choir pattern 1
    {
      t: 'triangle', // oscillator type
      a: 0.1, // attack time
      v: 0.2, // volume
      V: 0.1 , // decayed volume at end of note
      f: 1, // low-pass filter frequency in kHz
      F: .1, // decayed low-pass filter frequency in kHz
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
