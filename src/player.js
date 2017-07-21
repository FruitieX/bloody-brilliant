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

//B = {};

A = new AudioContext;

n = () => {
  osc = A.createScriptProcessor(512, 1, 1);

  osc.onaudioprocess = e =>
    e.outputBuffer.getChannelData(0).map((s, i) =>
      e.outputBuffer.getChannelData(0)[i] = Math.random() * 2 - 1
    );

  return osc;
};

// Init instruments
I = s.i.map(i => {
  o = A.createOscillator();
  e = A.createGain();
  l = A.createBiquadFilter();

  // Set oscillator type
  if (i.t == 'noise') {
    o = n();
  } else {
    o.type = i.t;
    // Start oscillator
    o.start();
  }

  // Oscillators start out silent, TODO: unnecessary?
  e.gain.value = 0;

  // Set filter Q value
  //l.Q.value = 12;

  // Connect oscillator to envelope
  o.connect(e);

  // Connect envelope to filter
  e.connect(l);

  // Connect filter to master out
  l.connect(A.destination);

  // TODO: object spread not supported by uglifyes, babili?
  return Object.assign({ o, e, l }, i);
});

// Program notes
for (l = s.l - 1; l > -1; l--) { // loop repetitions (in reverse order)
  for (r = s.r - 1; r > -1; r--) { // rows (in reverse order)
    I.map(i => { // for each instrument
      N = i.n[r % i.n.length];
      // Don't do anything if note is undefined
      if (!N) return;

      // Begin note from silence
      i.e.gain.setValueAtTime(
        // Volume
        0,

        // Start time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
      );
      // Note fades to full volume after attack time
      i.e.gain.linearRampToValueAtTime(
        // Volume
        N == -1 ? 0 : i.v,

        // Start time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
        + i.a       // Instrument attack
      );
      i.e.gain.setValueAtTime(
        // Volume
        N == -1 ? 0 : i.v,

        // Start time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
        + i.a       // Instrument attack
      );

      i.l.frequency.setValueAtTime(
        // Frequency
        i.f * 1000,

        // Start time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
      );

      i.t != 'noise' && i.o.frequency.setValueAtTime(
        // Frequency
        440 * Math.pow(2, (N - 48) / 12),

        // Start time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
      );

      // Fade previous note only if this is not the first note
      if (!l && !r) return;

      i.e.gain.linearRampToValueAtTime(
        // Decayed volume
        i.V,

        // End time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
        - 1e-3      // - delta
      );
      i.l.frequency.linearRampToValueAtTime(
        // Decayed frequency
        i.F * 1000,

        // End time
        (
          l * s.r + // Loop index * rows per loop
          r         // Row index
        ) * s.b     // * Seconds per row
        - 1e-3      // - delta
      );

      // Only glide notes if enabled
      if (!i.g) return;
      i.o.frequency.exponentialRampToValueAtTime(
        // Glide frequency
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

/*
waveforms = [
  "sine",
  "square",
  "sawtooth",
  "triangle",
];


createNoiseOsc = () => {
  osc = A.createScriptProcessor(2048, 1, 1);

  osc.onaudioprocess = e => {
      output = e.outputBuffer.getChannelData(0);
      for (i = 0; i < 2048; i++) {
          output[i] = Math.random() * 2 - 1;
      }
  }

  return osc;
};

F = [
  "highpass",
  "lowpass",
  "bandpass",
];

initCol = () => {
  //  master out / "post" filter mixer
  o = A.createGain();
  // "pre" filter mixer
  preFilter = A.createGain();

  // oscillator envelopes
  osc1env = A.createGain();
  osc2env = A.createGain();
  osc3env = A.createGain();

  // make sure oscillators start out muted
  osc1env.gain.value = osc2env.gain.value = osc3env.gain.value = 0;

  // oscillators
  osc1 = A.createOscillator();
  osc2 = A.createOscillator();
  osc3 = createNoiseOsc();

  // pan
  panNode = A.createStereoPanner();
  panLFO = A.createOscillator();
  panAmt = A.createGain();

  // delay
  delayGain = A.createGain();
  dly = A.createDelay();

  // filter
  biquadFilter = A.createBiquadFilter();

  // lfo
  lfo = A.createOscillator();
  modulationGain = A.createGain();

  osc1env.connect(preFilter);
  osc2env.connect(preFilter);
  osc3env.connect(preFilter);

  osc1.connect(osc1env);
  osc2.connect(osc2env);
  osc3.connect(osc3env);

  // delay output goes to master
  delayGain.connect(o);
  // connect delay to itself to create feedback loop
  delayGain.connect(dly);
  // connect delay to delayGain to allow fading it out
  dly.connect(delayGain);

  panNode.connect(o);
  panLFO.connect(panAmt);
  panAmt.connect(panNode.pan);

  preFilter.connect(biquadFilter);
  biquadFilter.connect(dly);
  biquadFilter.connect(panNode);

  lfo.connect(modulationGain);
  modulationGain.connect(biquadFilter.frequency);

  return {
    o,
    preFilter,
    osc1env,
    osc2env,
    osc3env,
    osc1,
    osc2,
    osc3,
    delayGain,
    dly,
    panNode,
    panLFO,
    panAmt,
    biquadFilter,
    lfo,
    modulationGain,
  };
};

initTrack = () => {
  // Support max 4 columns per track
  return [
    initCol(),
    initCol(),
    initCol(),
    initCol(),
  ];
};

setNotes = (params, patterns, patternOrder, l, r, when, column, cIndex) => {
  // TODO get rid of unused params
  // osc1t = waveforms[params[0]],
      o1vol = params[1] / 255,
      o1xenv = params[3],
      // osc2t = waveforms[params[4]],
      o2vol = params[5] / 255,
      o2xenv = params[8],
      noiseVol = params[9] / 255,
      attack = params[10] * params[10] * 4 / 44100,
      sustain = params[11] * params[11] * 4 / 44100,
      release = params[12] * params[12] * 4 / 44100,

  // parse song into more suitable format
  notes = [];
  effects = [];

  // program in all notes
  patternOrder.forEach((patIdx, numPattern) => {
    // loop over patterns
    if (patIdx) {
      pattern = patterns[patIdx - 1];
      n = pattern.n.slice(cIndex * r, cIndex * r + r);
      f = pattern.f.slice(cIndex * r, cIndex * r + r);

      for (i = 0; i < r; i++) {
        notes[numPattern * r + i] = n[i];
        effects[numPattern * r + i] = f[i];
      }
    }
  });

  // TODO: arpeggio
  //var o1t = getnotefreq(n + (arp & 15) + params[2] - 128);
  //var o2t = getnotefreq(n + (arp & 15) + params[6] - 128) * (1 + 0.0008 * params[7]);

  // Program notes in reverse order and keep track of the next note.
  // If next note is too close, don't program in sustain / release events
  notes.reverse();
  nextNote = 0;

  notes.forEach((note, index) => {
    if (!note) return;

    //startTime = t + l * index;
    startTime = when + l * (notes.length - index - 1);
    osc1freq = 440 * Math.pow(2, (note + params[2] - 272) / 12);
    osc2freq = 440 * Math.pow(2, (note + params[6] - 272 + 0.0125 * params[7]) / 12);
    column.osc1.frequency.setValueAtTime(osc1freq, startTime);
    column.osc2.frequency.setValueAtTime(osc2freq, startTime);

    // Envelope modulated frequency on oscillator 1
    if (o1xenv) {
      column.osc1.frequency.setValueAtTime(0, startTime);
      column.osc1.frequency.linearRampToValueAtTime(osc1freq, startTime + attack);

      if (!nextNote || nextNote > startTime + attack + sustain) {
        // sustain
        column.osc1.frequency.setValueAtTime(osc1freq, startTime + attack + sustain);
        // release
        column.osc1.frequency.linearRampToValueAtTime(0, startTime + attack + sustain + release);
      }
    }

    // Envelope modulated frequency on oscillator 2
    if (o2xenv) {
      column.osc2.frequency.setValueAtTime(0, startTime);
      column.osc2.frequency.linearRampToValueAtTime(osc2freq, startTime + attack);

      if (!nextNote || nextNote > startTime + attack + sustain) {
        // sustain
        column.osc2.frequency.setValueAtTime(osc2freq, startTime + attack + sustain);
        // release
        column.osc2.frequency.linearRampToValueAtTime(0, startTime + attack + sustain + release);
      }
    }

    att = startTime + attack;
    sus = startTime + attack + sustain;
    rel = startTime + attack + sustain + release;

    // small delta required so clamped events don't overlap
    d = 0.001;

    // don't overlap frequent events
    if (nextNote) {
      att = Math.min(nextNote - d, att);
      sus = Math.min(nextNote - d, sus);
      rel = Math.min(nextNote - d, rel);
    }

    // attack
    column.osc1env.gain.setValueAtTime(0, startTime);
    column.osc2env.gain.setValueAtTime(0, startTime);
    column.osc3env.gain.setValueAtTime(0, startTime);
    column.osc1env.gain.linearRampToValueAtTime(o1vol, att);
    column.osc2env.gain.linearRampToValueAtTime(o2vol, att);
    column.osc3env.gain.linearRampToValueAtTime(noiseVol, att);

    if (!nextNote || nextNote > startTime + attack + sustain) {
        // sustain
        column.osc1env.gain.setValueAtTime(o1vol, sus);
        column.osc2env.gain.setValueAtTime(o2vol, sus);
        column.osc3env.gain.setValueAtTime(noiseVol, sus);

        // release

        releaseVal = Math.max(0, Math.min(1 - (rel - startTime) / (attack + sustain + release), 1));
        column.osc1env.gain.linearRampToValueAtTime(o1vol * releaseVal, rel);
        column.osc2env.gain.linearRampToValueAtTime(o2vol * releaseVal, rel);
        column.osc3env.gain.linearRampToValueAtTime(noiseVol * releaseVal, rel);
    }

    nextNote = startTime;
  });
};

B.G = function() {
    // Support max 8 tracks
    this.tracks = [
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
      initTrack(),
    ];

    M = A.createGain();
    M.gain.value = 0.4;
    M.connect(A.destination);

    // connect each column in each track to the mixer and start oscillators
    this.tracks.forEach(track =>
      track.forEach(column => {
        column.o.connect(M);
        column.osc1.start();
        column.osc2.start();
        //column.osc3.start(); // TODO: start/stop noise osc
        column.lfo.start();
        column.panLFO.start();
      })
    );
};

B.G.prototype.play = function(song, when = 0) {
  song.d.forEach((track, tIndex) =>
    this.tracks[tIndex].forEach((column, cIndex) => {
      // TODO: better way of resetting lfo?
      // currently it's recreated
      column.lfo.disconnect();
      column.lfo = A.createOscillator();
      column.lfo.connect(column.modulationGain);
      column.lfo.start();

      column.panLFO.disconnect();
      column.panLFO = A.createOscillator();
      column.panLFO.connect(column.panAmt);
      column.panLFO.start();

      // set params
      osc1t = waveforms[track.i[0]],
      osc2t = waveforms[track.i[4]],
      oscLFO = waveforms[track.i[15]],
      lfoAmt = track.i[16] / 255,
      lfoFreq = Math.pow(2, track.i[17] - 9) / song.l / 44100 * 2,
      fxLFO = track.i[18],
      fxFilter = track.i[19],
      fxFreq = track.i[20] * 20,
      q = Math.pow(track.i[21] / 255, 2) * 10,
      //dist = track.i[22] * 1e-5,
      drive = track.i[23] / 32,
      panAmt = track.i[24] / 255,
      panFreq = 3.14 * Math.pow(2, track.i[25] - 9) / song.l / 44100,
      dlyAmt = track.i[26] / 255,
      dly = track.i[27] * song.l /44100 / 2;

      // master
      column.o.gain.value = drive;
      column.preFilter.gain.value = 1;

      // oscillators
      column.osc1env.gain.value = 0;
      column.osc2env.gain.value = 0;
      column.osc3env.gain.value = 0;

      column.osc1.type = osc1t;
      column.osc2.type = osc2t;

      // pan
      column.panAmt.gain.value = panAmt;
      // TODO: correct value?
      column.panLFO.frequency.value = panFreq;

      // delay
      column.delayGain.gain.value = dlyAmt;

      column.dly.delayTime.value = dly;

      // filter
      column.biquadFilter.type = F[fxFilter - 1];
      column.biquadFilter.frequency.value = fxFreq;
      column.biquadFilter.Q.value = q;

      if (fxLFO) {
        // lfo
        column.lfo.type = oscLFO;
        column.lfo.frequency.value = lfoFreq;

        // TODO: whats the correct value?
        column.modulationGain.gain.value = lfoAmt * 1000;

      } else {
        // disable LFO
        column.modulationGain.gain.value = 0;
      }

      // Program notes for each oscillator
      setNotes(track.i, track.c, track.p, song.l / 44100, song.r, when, column, cIndex);
    })
  );
};
*/
