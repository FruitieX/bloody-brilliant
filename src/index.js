// potato level for PC, higher = faster :-)
// TODO: remove in production
potato = 6;
c.width = 1920 / potato;
c.height = 1080 / potato;

// music
//b.connect(A.destination);
// analyser = soundbox.audioCtx.createAnalyser();
// analyserArray = new Uint8Array(analyser.frequencyBinCount);

// connect kick drum track, first column to analyser
// b.tracks[0][0].out.connect(analyser);

// connect hihat drum track, first column to analyser
// b.tracks[2][0].out.connect(analyser);

// time at previous frame
oldTime = 0;

// accumulators
bPeak = 0; // bass peak, max(bass, bPeak)

// simulate heart pumping the blood rythm
lBeat = 1.411764;

// gfx
g = c.getContext`webgl`;
P = g.createProgram();

// NOTE: 2nd argument to drawArrays used to be 0, but undefined works
r = t =>
  g.drawArrays(
    g.TRIANGLE_FAN,

    // a.xy = resolution
    // a.z = time (s)
    // a.w = unused
    g.uniform4f(
      g.getUniformLocation(P, 'a'),
      c.width,
      c.height,
      A.currentTime,
      0 // TODO: must pass 4 params
    ),

    // number of indices to be rendered
    3,

    // b.x = bass
    // b.y = accumulated bass
    // b.z = unused
    // b.w = unused
    g.uniform4f(
      g.getUniformLocation(P, 'b'),

      // bass peak, averaged. TODO: can we use blood flow instead?
      bPeak = //Math.max(
        0.97 * bPeak + 0.2 * .1 /*b.tracks[0][0].osc1env.gain.value*/ *
          (d = (t - oldTime) / 16),
        //b.tracks[0][0].osc1env.gain.value
      //),

      // blood flow
      Math.floor(A.currentTime/lBeat)*.841 +
      (
        A.currentTime % lBeat > .53
        ? .841
        : Math.sqrt(
          Math.sin(
            A.currentTime % lBeat / .53 * 3. * Math.PI / 4.)
          )
      ),
      //requestAnimationFrame(r),

      // battery saving
      setTimeout(() => requestAnimationFrame(r), 1000),
      oldTime = t // unused
    )
  );

// vertex shader
g.shaderSource(S=g.createShader(g.VERTEX_SHADER), require("./vertex.glsl"));
g.compileShader(S);g.attachShader(P,S);

// fragment shader
g.shaderSource(S=g.createShader(g.FRAGMENT_SHADER), require("./fragment.glsl"));
g.compileShader(S);g.attachShader(P,S);

// Log compilation errors
// TODO: remove in production
if (!g.getShaderParameter(S, 35713)) { // COMPILE_STATUS = 35713
  throw g.getShaderInfoLog(S);
}

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
