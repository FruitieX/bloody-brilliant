// production, 4K
/*
c.width = 3840;
c.height = 2160;
*/
// production, 1080p
/*
c.width = 1920;
c.height = 1080;
*/

// debug, 1080p / 2
c.width = 960;
c.height = 540;

// accumulators
b = 0; // bass avg
T = 0; // oldTime

// gfx
g = c.getContext`webgl`;
P = g.createProgram();

// NOTE: 2nd argument to drawArrays used to be 0, but undefined works
R = t =>
  g.drawArrays(
    g.TRIANGLE_FAN,

    // a.xy = resolution
    // a.z = time (s)
    // a.w = bass
    g.uniform4f(
      g.getUniformLocation(P, 'a', B = Math.pow(0.995, t - T)),
      c.width,
      c.height,
      A.currentTime,
      // framerate independent moving average:
      // https://www.gamedev.net/forums/topic/499983-smooth-framerate-independent-chase-camera/#comment-4261584
      b = B * b + (1 - B) * I[0].e.gain.value,

      requestAnimationFrame(R, T = t)

      // battery saving
      // setTimeout(() => requestAnimationFrame(R, T = t), 200)
    ),

    // number of indices to be rendered
    3
  );

// vertex shader
g.shaderSource(S=g.createShader(g.VERTEX_SHADER), require("./vertex.glsl"));
g.compileShader(S);g.attachShader(P,S);

// fragment shader
g.shaderSource(S=g.createShader(g.FRAGMENT_SHADER), require("./fragment.glsl"));
g.compileShader(S);g.attachShader(P,S);

// Log compilation errors
// if (!g.getShaderParameter(S, 35713)) { // COMPILE_STATUS = 35713
//   throw g.getShaderInfoLog(S);
// }

g.bindBuffer(g.ARRAY_BUFFER, g.createBuffer(c.style = 'height:1e2vh'));

//c.parentElement.style = 'cursor:none;margin:0;overflow:hidden';

// 1st argument to enableVertexAttribArray used to be 0, but undefined works
// 1st argument to vertexAttribPointer used to be 0, but undefined works
g.vertexAttribPointer(
  g.enableVertexAttribArray(
    g.bufferData(g.ARRAY_BUFFER, Int8Array.of(-3, 1, 1, -3, 1, 1), g.STATIC_DRAW)
  ),
2, g.BYTE, 0, g.linkProgram(P), g.useProgram(P));

// music

A = new AudioContext;

// Init instruments
I = s.i.map(i => {
  o = A.createOscillator();
  e = A.createGain();
  l = A.createBiquadFilter();
  d = A.createDelay();
  f = A.createGain();

  // Set oscillator type
  o.type = i.t;

  // Start oscillator
  o.start();

  // Oscillators start out silent, TODO: unnecessary?
  e.gain.value = 0;
  f.gain.value = i.d || 0;
  d.delayTime.value = .3;

  // Set filter Q value
  //l.Q.value = 12;

  l.type = i.T;

  // Connect oscillator to envelope
  o.connect(e);

  // Connect envelope to filter
  e.connect(l);

  // connect to (slapback) delay if key exists
  l.connect(f);

  // connect delay to feedback and back so it echoes out
  f.connect(d);
  d.connect(f);

  // finally, connect delay to filter
  a = A.destination;
  d.connect(a);

  // Connect filter to master
  l.connect(a);

  return Object.assign({ o, e, l }, i);
});

// Program notes
for (l = 0; l < s.l; l++) { // loop repetitions (in reverse order)
  for (r = 0; r < s.r; r++) { // rows (in reverse order)
    I.map(i => { // for each instrument
      // Rate divisor defaults to 1
      i.r = i.r || 1;

      // Note index
      n = (r / i.r) % i.n.length;

      N = i.A
        // Arpeggio, ~~ does Math.floor()
        ? i.n[~~n][((r % i.r) * i.A) % i.n[~~n].length]
        // Normal notes
        : i.n[n];

      // Instrument was just muted: insert off note
      if (i.M - 1 < l) N = -1;
      else if (
        // Otherwise don't do anything once instrument is muted
        i.m > l |
        // Or if note is undefined
        !N
      ) return;

      // Start time
      t = (
        l * s.r + // Loop index * rows per loop
        r         // Row index
      ) * s.b;    // * Seconds per row

      // ATTACK
      i.e.gain.setValueAtTime(
        // Note starts at silence
        0, t
      );
      i.e.gain.setValueAtTime(
        // Full volume after attack, unless this is an off note
        N < 0 ? 0 : i.v, t + .02       // Instrument attack
      );
      i.e.gain.linearRampToValueAtTime(
        // Fade to full volume after attack, unless this is an off note
        N < 0 ? 0 : i.v, t + .02       // Instrument attack
      );

      // LOW-PASS FILTER FREQUENCY
      i.l.frequency.setValueAtTime(
        i.f * 1e3, t
      );

      // OSCILLATOR FREQUENCY
      i.o.frequency.setValueAtTime(
        440 * Math.pow(2, (N - i.N) / 12), t
      );

      // Previous note was an off note - there's nothing to decay
      if (i.P < 0) {
        i.P = N;
        return;
      }

      // Store previous note
      i.P = N;

      // This is the first note - there's nothing to decay
      if (!r && !l) return;

      // DECAY PREVIOUS NOTE
      i.e.gain.linearRampToValueAtTime(
        // Volume of previous note right before this note
        0, t - 1e-3      // - delta
      );
      i.l.frequency.linearRampToValueAtTime(
        // Low-pass filter frequency right before next note
        i.F * 1e3, t - 1e-3      // - delta
      );

      if (!i.g) return; // Only glide notes if glide enabled
      i.o.frequency.exponentialRampToValueAtTime(
        // Oscillator frequency right before next note
        i.g, t - 1e-3      // - delta
      );
    });
  }
}

// render first frame
R(0);
