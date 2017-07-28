// production, 4K
/*
c.width = 3840;
c.height = 2160;
*/
// production, 1080p
/*
c.width = 3840;
c.height = 2160;
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
  f.gain.value = ("d" in i ? i.d : 0);
  d.delayTime.value = .25;

  // Set filter Q value
  //l.Q.value = 12;

  l.type = i.T;

  // Connect oscillator to envelope
  o.connect(e);

  // Connect envelope to filter
  e.connect(l);

  // connect to (slapback) delay if key exists
  if ("d" in i) e.connect(d);

  // connect delay to feedback and back so it echoes out
  d.connect(f);
  f.connect(d);
  // finally, connect delay to filter
  d.connect(l);

  // Connect filter to master
  l.connect(A.destination);

  return Object.assign({ o, e, l }, i);
});

// Program notes
for (l = 0; l < s.l; l++) { // loop repetitions (in reverse order)
  for (r = 0; r < s.r; r++) { // rows (in reverse order)
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

      // TODO: golf?
      
      // Previous note was an off note - there's nothing to decay
      if (i.P == -1) {
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

// render first frame
R(0);
