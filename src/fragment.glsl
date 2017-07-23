precision highp float;

// a.xy = resolution
// a.z = time (s)
// a.w = bass
uniform vec4 a;

float PI = 3.14;

float calcPlasma(vec3 p, float t) {
  return length(sin(sin(p) + t));
}

float smin( float a, float b, float k ) {
  return -log(exp( -k*a ) + exp( -k*b ))/k;
}

vec4 opI( vec4 d1, vec4 d2 ) {
    return d1.x < d2.x ? d2 : d1;
}

vec4 opBlend( vec4 d1, vec4 d2, float k ) {
  float tot = d1.x + d2.x;

  return vec4(
    smin( d1.x, d2.x, k ),
    1. / tot * (d1.yzw * (tot - d1.x) + d2.yzw * (tot - d2.x))
  );
}

vec4 opU(vec4 d1, vec4 d2) {
  return d1.x < d2.x ? d1 : d2;
}

// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float fCapsule(vec3 p, float r, float c) {
	return mix(length(p.xz) - r, length(vec3(p.x, abs(p.y) - c, p.z)) - r, step(c, abs(p.y)));
}

float sdBloodCell(vec3 p) {
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(.3,.06);

  return smin(
    length(vec2(length(p.xz)-.3,p.y)) - .1,
    clamp(d.x, d.y, 0.) + length(max(d,0.)),
    32.
  );
}

float sdTorus(vec3 p) {
  // the first constant sets size of torus
  // second sets size of middle
  return -(length(vec2(length(p.xz)-14.,p.y)) - 3.);
}

float sdTriPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x+.5*p.y, -p.y)-h.x*.5);
}

float sdHexPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x+.5*q.y, q.y)-h.x);
}

vec4 heart(vec3 p) {
  float plasma1 = calcPlasma(p * 2., a.z / 10.) + .5;

  return vec4(
    // tunnel shape
    (1. - a.w * .5) * (cos(p.x) + sin(p.y) + sin(p.z)) / 5.

    // blobby surface
    + (1. - a.w * 2.) * .05 * sin(10. * p.x) * sin(10. * p.y) * sin(10. * p.z) * sin(plasma1),

    // color
    sin(vec3(1., .2, .1) * plasma1)
  );
}

float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2.*PI/repetitions,
      	a = atan(p.y, p.x) + angle/2.,
      	c = floor(a/angle);
	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*length(p);
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2.)) c = abs(c);
	return c;
}

vec4 bloodCellField(vec3 p) {
  // set up the correct rotation axis
  p.z += 3.;
  p.x += 15.; // move rotational origo to center of blood vein
  pR(p.xz, -(4. * a.z + 2. * a.w) / 20.); // give speed to blood wall
  pModPolar(p.xz, 24.); // Rotate and duplicate blood wall around torus origo
  p -= vec3(15.,0.,0.);

  vec3 col = vec3(1., .1, .1);

  vec3 rotated = p - vec3(1.,-1.,0.);
  pR(rotated.yz, a.z / 6.);
  vec4 res = vec4(sdBloodCell(rotated), col);

  // repeat
  rotated = p + vec3(0.,2.,0.);
  pR(rotated.xy, a.z / 6.);
  res = opU(res, vec4(sdBloodCell(rotated), col));

  // repeat
  rotated = p + vec3(2.,1.,.5);
  pR(rotated.yz, a.z / 7.);
  res = opU(res, vec4(sdBloodCell(rotated), col));

  // repeat
  rotated = p + vec3(1.,-1.5,1.);
  pR(rotated.xy, a.z / 6.);
  res = opU(res, vec4(sdBloodCell(rotated), col));

  // repeat
  rotated = p + vec3(2.,-1.,0.);
  pR(rotated.xz, a.z / 6.);
  res = opU(res, vec4(sdBloodCell(rotated), col));

  // repeat
  rotated = p - vec3(.8,1.,0.);
  pR(rotated.xy, a.z / 7.);
  res = opU(res, vec4(sdBloodCell(rotated), col));

  return res;
}

vec4 bloodVein(vec3 p) {
  // rotate
  // pR(p.xy, a/5.);
  return vec4(
    // tunnel shape
    sdTorus(p + vec3(14.,0.,1.5))

    // blobby surface
    - 0.05 * (1. - sin(3. * (p.z - 2. * a.z)))

    + 2. * a.w,

    // color
    sin(vec3(1., .1, .1) * (calcPlasma(p * 2., a.z / 10.) + .5))
  );
}

vec4 virus(vec3 pos, float size) {
  // velocity
  pR(pos.xy, PI/4.);

  vec4 res = vec4(length(pos) - .5 * size - a.w / 5., 0., 1., 0.);

  pModPolar(pos.yz, 7.);

  vec4 spikes =
    vec4(fCapsule(
      pos,
      0.01 * size,
      size
    ), 1., .6, 1.);

  pR(pos.xy, PI/4.);

  spikes = opU(
    spikes,
    vec4(fCapsule(
      pos,
      0.01 * size,
      size
    ), 1., .6, 1.)
  );

  pR(pos.xy, PI/4.);

  spikes = opU(
    spikes,
    vec4(fCapsule(
      pos,
      0.01 * size,
      size
    ), 1., .6, 1.)
  );

  pR(pos.xy, PI/4.);

  spikes = opU(
    spikes,
    vec4(fCapsule(
      pos,
      0.01 * size,
      size
    ), 1., .6, 1.)
  );

  res = opBlend(
    res,
    spikes,
    9.
  );

  return res;
}

vec4 vessel(vec3 pos, bool laser) {
  vec3 col = vec3(.1);

  pR(pos.xy, PI/2.);
  vec4 res = vec4(sdTriPrism(pos , vec2(.25,.15)), col);
  pR(pos.xz, PI/2.);
  res = opI(res, vec4(sdTriPrism(pos , vec2(.35)), col));
  pR(pos.zy, PI/2.);
  res = opI(res, vec4(sdHexPrism(pos, vec2(.15,.25)), col));
  pos.z += .3;
  res = opU(res, vec4(sdHexPrism(pos, vec2(.15,.2)), col));

  pR(pos.yz, PI/2.);
  res = opU(res, vec4(sdTriPrism(pos , vec2(.4,.005)), col));
  pR(pos.xz, PI/2.);
  pos.x += .1;
  pos.y += .1;
  res = opU(res, vec4(sdTriPrism(pos , vec2(.195,.005)), col));

  if (laser) {
    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2.3, -.15), .01 + .005 * sin(10. * pos.y + 20. * a.z), 2.),
        vec3(abs(sin(a.z * 10. + pos.y * 10.)), .2, .3)
      )
    );

    pos.z -= .3;

    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2.3, -.15), .01 + .005 * sin(10. * pos.y + 20. * a.z), 2.),
        vec3(abs(sin(a.z * 10. + pos.y * 10.)), .2, .3)
      )
    );
  }

  return res;
}

vec4 scene1(vec3 pos, float t) {
  vec3 p_vessel = pos + vec3(.1-.2 * sin(t/PI),.6 + .2 * cos(t/PI),1.);

  // left-right tilt
  pR(p_vessel.xz, PI/2.-PI/12.*cos(t/PI));
  // up-down tilt
  pR(p_vessel.yz, -PI/16.*sin(t/PI));
  vec4 res = vessel(p_vessel, false);

  // rotation to blood cells and vein
  pR(pos.xy, t/PI);

  // render blood vein and cells
  res = opU(res, bloodVein(pos));
  res = opU(res, bloodCellField(pos));

  return res;
}

vec4 scene3(vec3 pos, float t) {
  pR(pos.yz, 7.);
  pR(pos.xy, t/20.);
  pos += vec3(1.);
  return opBlend(
    heart(pos),
    virus(pos + vec3(.5), 1.),
    50.
  );
}

vec4 scene4(vec3 pos, float t) {
  pR(pos.xy, -.4);
  pR(pos.xz, -.8 + t / 32.);
  pos += vec3(cos(t / 6.), 0.5, 2.5 + cos(t / 6.));

  // vessel
  vec4 res = opBlend(
    heart(pos),
    virus(pos + vec3(.5), 1.),
    50.
  );

  pR(pos.xz, PI / 6.);
  pR(pos.xy, PI / 8.);

  // left-right tilt
  pR(pos.xz, PI/12.*cos(t/PI));
  // up-down tilt
  pR(pos.yz, -PI/16.*sin(t/PI));
  return opBlend(
    res,
    vessel(pos - vec3(
      2.5 + 1.5 * cos(1. + min(t, (PI - 1. ) * 8.) / 8.),
      0.,
      .5
    ), false),
    30.
  );
}

vec4 scene4_1(vec3 pos, float t) {

  pR(pos.yz, .7);
  pR(pos.xz, -3.);
  pos += vec3(t / 16. - .5,1.,-1.);
  //pR(pos.zy, t);
  // vessel
  vec4 res = opBlend(
    heart(pos),
    virus(pos + vec3(.5), 1. / (1. + t / 10.)),
    50.
  );

  pR(pos.xz, PI / 6.);
  pR(pos.xy, PI / 8.);

  // left-right tilt
  pR(pos.xz, PI/12.*cos(t/PI));
  // up-down tilt
  pR(pos.yz, -PI/16.*sin(t/PI));
  return opBlend(
    res,
    vessel(pos - vec3(1., 0., -.2), t > 2.),
    15.
  );
}

vec4 map(vec3 pos) {
  float t = a.z;
  /* ---------- DEBUGGING ---------- */
  // Uncomment when debugging single scene
  // return scene4(pos, a.z);

  /* ---------- SCENES --------- */
  if ((t -= 16.) < 0.) {
    // nanobot
    return scene1(pos, t + 16.);
  } else if ((t -= 16.) < 0.) {
    // virus
    return scene3(pos, t + 16.);
  } else if ((t -= 16.) < 0.) {
    // nanobot, TODO: viruses on blood vein walls?
    return scene1(pos, t + 16.);
  } else if ((t -= 16.) < 0.) {
    // nanobot approaches virus
    return scene4(pos, t + 16.);
  } else if ((t -= 16.) < 0.) {
    // nanobot fires lasers
    return scene4_1(pos, t + 16.);
  } else {
    return vec4(0.);
  }
}

void main() {

  vec3 col = vec3(0.),
       tot = vec3(0.),
       ro = vec3(0., 0., 1.),
       pos;

  for( float m=0.; m<2.; m++ )   // 2x AA
  for( float n=0.; n<2.; n++ ) { // 2x AA
    vec4 res; // = vec3(-1.);
    float t = .0; // tmin

    // ray direction
    vec3 rd =
      // camera-to-world transformation
      mat3(ro.zxx, ro.xzx, -ro) *

      normalize(
        vec3(
          // pixel coordinates
          (
            2. * (
              gl_FragCoord.xy + vec2(m, n) / 2. - .5
            ) - a.xy
          ) / a.y,
          2.
        )
      );

    for(float i = 0.; i < 64.; i++) // 64. = maxIterations
      t += (res = map(pos = ro + rd * t)).x;

    vec2 e = vec2(1e-2, -1e-2);

    vec3 nor = normalize(
      e.xyy * map(pos + e.xyy).x +
      e.yyx * map(pos + e.yyx).x +
      e.yxy * map(pos + e.yxy).x +
      e.xxx * map(pos + e.xxx).x
    ),
    ref = reflect(rd, nor),

    lig = vec3(.7); // direction of light

    // material
    float amb = nor.y,
          dif = max(dot(nor, lig), 0.),
          //dom = smoothstep(-.1, .1, ref.y),
          dom = ref.y,
          fre = pow(min(dot(nor, rd) + 1., 1.), 2.),
          spe = pow(dot(ref, lig), 2.);

    if(length(res.yzw) > 0.)
      col = res.yzw * (
        dif
          + spe * dif
          + pow(.4 * amb, 2.)
          + pow(.2 * dom, 4.)
          + .5 * fre
      );

    tot += pow(
      // fog
      mix(col, vec3(.03, .04, .05), 1. - exp(-.001 * t * t * t)),

    	// gamma
      vec3(.6, .5, .4)
    );
  }

  gl_FragColor = vec4(tot / 4., 1.); // 4 = AA * AA
}
