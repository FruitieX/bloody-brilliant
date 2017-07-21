s = {
  b: .125, // seconds per row: (BPM / 60) / (rows per beat)
  r: 128,  // rows per loop
  l: 16,  // loops

  // Instruments
  i: [{
    // Kick drum
    // oscillator is sine by default
    //t: 'sine', // oscillator type
    a: 0.01, // attack time
    v: 0.5, // volume
    V: 0, // decayed volume at end of note
    f: 1, // low-pass filter frequency in kHz
    F: 0.1, // decayed low-pass filter frequency in kHz
    m: 0, // muted for this many loops
    M: 8, // muted after this many loops
    g: 10, // glide notes to this frequency in Hz (useful for kicks drums)

    // notes, -1 = off note
    n: [
      37,,,34,
      ,,-1,,
    ],
  }, {
    // Percussion 1 (Snare)
    t: 'square', // oscillator type
    a: 0.01, // attack time
    v: 0.5, // volume
    V: 0, // decayed volume at end of note
    f: 10, // low-pass filter frequency in kHz
    F: 10, // decayed low-pass filter frequency in kHz
    m: 0, // muted for this many loops
    M: 8, // muted after this many loops
    g: 10, // glide notes to this frequency in Hz (useful for kicks drums)

    // notes, -1 = off note
    n: [
      ,,,,42,,-1,,
      ,,,,42,,-1,,
      ,,,,42,,-1,,
      ,,,42,,,,-1,
    ],
  }, {
    // Percussion 2 (Hi-hat)
    t: 'noise', // oscillator type
    a: 0.001, // attack time
    v: 0.3, // volume
    V: 0, // decayed volume at end of note
    f: 15, // low-pass filter frequency in kHz
    F: 15, // decayed low-pass filter frequency in kHz
    m: 0, // muted for this many loops
    M: 8, // muted after this many loops

    // notes, -1 = off note
    n: [
      1
    ],
  }, {
    t: 'square', // oscillator type
    a: 0.01, // attack time
    v: 0.2, // volume
    V: 0.2, // decayed volume at end of note
    f: 0.05, // low-pass filter frequency in kHz
    F: 10, // decayed low-pass filter frequency in kHz
    m: 0, // muted for this many loops
    M: 8, // muted after this many loops

    // notes, -1 = off note
    n: [
      24,,,,,,,, 24,,,,,,,, 27,,,,,,,, 27,,,,,,,, 20,,,,,,,, 20,,,,,,,, 19,,,,,,,, 19,,,,,,,,
      24,,,,,,,, 24,,,,,,,, 27,,,,,,,, 27,,,,,,,, 20,,,,,,,, 20,,,,,,,, 17,,,,,,,, 17,,,,,,,,
    ],
  }, {
    t: 'square', // oscillator type
    a: 0.01, // attack time
    v: 0.2, // volume
    V: 0.2, // decayed volume at end of note
    f: 0.05, // low-pass filter frequency in kHz
    F: 10, // decayed low-pass filter frequency in kHz
    m: 0, // muted for this many loops
    M: 8, // muted after this many loops

    // notes, -1 = off note
    n: [
      31,,,,,,,, 31,,,,,,,, 34,,,,,,,, 34,,,,,,,, 27,,,,,,,, 27,,,,,,,, 26,,,,,,,, 26,,,,,,,,
      31,,,,,,,, 31,,,,,,,, 34,,,,,,,, 34,,,,,,,, 34,,,,,,,, 34,,,,,,,, 32,,,,,,,, 32,,,,,,,,
    ],
  }, {
    t: 'square', // oscillator type
    a: 0.01, // attack time
    v: 0.2, // volume
    V: 0.01, // decayed volume at end of note
    f: 10, // low-pass filter frequency in kHz
    F: 1, // decayed low-pass filter frequency in kHz
    m: 0, // muted for this many loops
    M: 8, // muted after this many loops

    // notes, -1 = off note
    n: [
      36,, 31,, 36,, 31,, 36,, 31,, 36,, 31,,
      39,, 34,, 39,, 34,, 39,, 34,, 39,, 34,,
      32,, 27,, 32,, 27,, 32,, 27,, 32,, 27,,
      31,, 26,, 31,, 26,, 31,, 26,, 31,, 26,,

      36,, 31,, 36,, 31,, 36,, 31,, 36,, 31,,
      39,, 34,, 39,, 34,, 39,, 34,, 39,, 34,,
      34,, 27,, 34,, 27,, 34,, 27,, 34,, 27,,
      32,, 29,, 32,, 29,, 32,, 29,, 32,, 29,,
    ],
  }]
};
