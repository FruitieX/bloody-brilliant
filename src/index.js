// potato level for PC, higher = faster :-)
// TODO: remove in production
/*
potato = 8;
c.width = 1920 / potato;
c.height = 1080 / potato;
*/
// production
/*
c.width = 1920;
c.height = 1080;
*/
c.width = 240;
c.height = 135;

// music
//b.connect(A.destination);
// analyser = soundbox.audioCtx.createAnalyser();
// analyserArray = new Uint8Array(analyser.frequencyBinCount);

// connect kick drum track, first column to analyser
// b.tracks[0][0].out.connect(analyser);

// connect hihat drum track, first column to analyser
// b.tracks[2][0].out.connect(analyser);

// time at previous frame
//oldTime = 0;

// accumulators
//bPeak = 0; // bass peak, max(bass, bPeak)
b = 0; // bass avg
T = 0; // oldTime

// simulate heart pumping the blood rythm
//lBeat = 1;

// gfx
g = c.getContext`webgl`;
P = g.createProgram();

// NOTE: 2nd argument to drawArrays used to be 0, but undefined works
r = t =>
  g.drawArrays(
    g.TRIANGLE_FAN,

    // a.xy = resolution
    // a.z = time (s)
    // a.w = bass
    g.uniform4f(
      g.getUniformLocation(P, 'a'),
      c.width,
      c.height,
      A.currentTime,
      // framerate independent moving average:
      // https://www.gamedev.net/forums/topic/499983-smooth-framerate-independent-chase-camera/#comment-4261584
      b = Math.pow(0.995, t - T) * b + (1 - Math.pow(0.995, t - T)) * I[0].e.gain.value,
      requestAnimationFrame(r, T = t)
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

g.bindBuffer(g.ARRAY_BUFFER, g.createBuffer(c.parentElement.style.margin = 0));

c.parentElement.style.cursor = 'none';
c.style.height = '1e2vh';

// 1st argument to enableVertexAttribArray used to be 0, but undefined works
// 1st argument to vertexAttribPointer used to be 0, but undefined works
g.vertexAttribPointer(
  g.enableVertexAttribArray(
    g.bufferData(g.ARRAY_BUFFER, Int8Array.of(-3, 1, 1, -3, 1, 1), g.STATIC_DRAW)
  ),
2, g.BYTE, r(0), g.linkProgram(P), g.useProgram(P));
