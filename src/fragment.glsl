precision highp float;

// a.xy = resolution
// a.z = time (s)
// a.w = bass
uniform vec4 a;

float PI = 3.14;

vec4 opI( vec4 d1, vec4 d2 ) {
  return d1.x < d2.x ? d2 : d1;
}

vec4 opBlend( vec4 d1, vec4 d2, float k ) {
  return vec4(
    -log( exp(-k * d1.x) + exp(-k * d2.x)) / k,
    (d1.yzw * d2.x + d2.yzw * d1.x) / (d1.x + d2.x)
  );
}

vec4 opU(vec4 d1, vec4 d2) {
  return d1.x < d2.x ? d1 : d2;
}

// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
vec2 pR(inout vec2 p, float a) {
	return p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float fCapsule(vec3 p, float r, float c) {
	return mix(length(p.xz) - r, length(vec3(p.x, abs(p.y) - c, p.z)) - r, step(c, abs(p.y)));
}

float sdBloodCell(vec3 p) {
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(.3,.06);

  return opBlend(
    vec4(length(vec2(length(p.xz)-.3,p.y)) - .1),
    vec4(clamp(d.x, d.y, 0.) + length(max(d,0.))),
    32.
  ).x;
}

float sdTriPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x+.5*p.y, -p.y)-h.x*.5);
}

/*
float sdHexPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x+.5*q.y, q.y)-h.x);
}
*/

vec4 heart(vec3 p, float colorMod) {
  return vec4(
    // tunnel shape
    (.2 - a.w * .1) * (cos(p.x) + sin(p.y) + sin(p.z))

    // blobby surface
    + (.04 - a.w * .1) * sin(5. * p.x) * sin(5. * p.y) * sin(5. * p.z),

    // color
    vec3(.9, .2, .1) * colorMod
  );
}

float pModPolar(inout vec2 p, float repetitions) {
	float angle = PI/repetitions,
      	a = mod(atan(p.y, p.x) + angle, angle*2.) - angle,
      	c = floor(a/angle/2.);
	p = vec2(cos(a), sin(a))*length(p);
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	// if (abs(c) >= (repetitions/2.)) c = abs(c); // deleting this didn't make any visible changes
	return c;
}

vec4 bloodCellField(vec3 pos) {
  // set up the correct rotation axis
  pos.x += 15.; // move rotational origo to center of blood vein
  pR(pos.xz, -.2 * a.z - .1 * a.w); // give speed to blood wall
  pModPolar(pos.xz, 12.); // Rotate and duplicate blood wall around torus origo
  pos.x -= 15.;

  // rotate blood cell ring
  pR(pos.xy, a.z / 10.);
  pR(pos.xz, .3);
  pModPolar(pos.xy, 5.); // Rotate and duplicate blood cell into ring around z axis
  pModPolar(pos.xz, 7.); // Rotate and duplicate ring around y axis

  // rotate individual blood cell
  pR(pos.yz, 1.5 + sin(a.z / 10.));

  // offset individual blood cell
  pos.x -= 2.2;

  return vec4(
    sdBloodCell(pos),
    1., .1, .1
  );
}

vec4 bloodVein(vec3 p) {
  // rotate
  // pR(p.xy, a/5.);
  p += vec3(14., 0., 1.5);
  return vec4(
    // tunnel shape
    // the first constant sets size of torus
    // second sets size of middle
    -length(vec2(length(p.xz)-14.,p.y)) + 3.

    // blobby surface
    - .05 * (1. - sin(3. * (p.z - 2. * a.z)))

    + 2. * a.w,

    // color
    .9, .1, .1
  );
}

vec4 virus(vec3 pos, float size) {
  vec4 res = vec4(
    length(pos) - .5 * size - a.w / 5.,
    0., 1., 0.
  );

  pModPolar(pos.yz, 7.);
  pModPolar(pos.yx, 7.);
  pos.y -= .5 * size;

  return opBlend(res,
    vec4(
      fCapsule(
        pos,
        .01 * size,
        .5 * size
      ),
      1., .6, 1.
    ),
    9.
  );
}

vec4 vessel(vec3 pos, float laser) {
  vec3 col = vec3(.1);

  pR(pos.xy, PI/2.);
  vec4 res = vec4(sdTriPrism(pos , vec2(.25,.15)), col);
  pR(pos.xz, PI/2.);
  //res = opI(res, vec4(sdTriPrism(pos , vec2(.35)), col));
  pR(pos.zy, PI/2.);
  res = opI(res, vec4(sdTriPrism(pos, vec2(.15,.25)), col));
  pos.z += .3;
  res = opU(res, vec4(sdTriPrism(pos, vec2(.15,.2)), col));

  pR(pos.yz, PI/2.);
  res = opU(res, vec4(sdTriPrism(pos , vec2(.4,.01)), col));
  pR(pos.xz, PI/2.);
  pos.xy += .1;
  //pos.x += .1;
  //pos.y += .1;
  res = opU(res, vec4(sdTriPrism(pos , vec2(.2,.01)), col));

  if (laser > 0.) {
    // TODO: pos += vec3(.1, 2.3, -.15) ?
    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2.3, -.15), .001, 2.) / 3.,
        10., .2, .3
      )
    );

    pos.z -= .3;

    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2.3, -.15), .001, 2.) / 3.,
        10., .2, .3
      )
    );
  }

  return res;
}

vec4 map(vec3 pos) {
  float t = a.z;
  vec4 res;
  vec3 temp = pos;

  // SCENE 1: Inside heart
  if ((t -= 19.2) < 0.) {
    pR(pos.xz, t / 6.); pR(pos.xy, t / 5.);

    return heart(pos + 1., 1.);
  }

  // SCENE 2: Nanobot in blood vein
  else if ((t -= 19.2) < 0.) {
    // move vessel forward
    pos += vec3(0., .25, .5);

    // rotation to blood cells and vein
    pR(temp.xy, t/PI);

    // rotate
    pR(pos.xz, 3. * PI / 6.);

    // left-right tilt, up-down tilt
    pR(pos.xz, -PI/12.*cos(t/PI)); pR(pos.yz, PI/16.*sin(t/PI));

    // render blood vein and cells
    return opU(
      opU(
        vessel(pos, 0.),
        bloodVein(temp)
      ),
      bloodCellField(temp)
    );
  }

  // SCENE 3: Virus in heart
  else if ((t -= 19.2) < 0.) {
    pR(pos.yz, 7.);
    pR(pos.xy, t/20.);
    pos += vec3(1.);
    return opBlend(
      heart(pos, -t / 19.2),
      virus(pos + vec3(.5), 1.),
      50.
    );
  }

  // SCENE 4: Nanobot in blood vein, TODO: viruses on walls?
  else if ((t -= 19.2) < 0.) {
    // move vessel forward
    pos += vec3(0., .25, .5);

    // rotation to blood cells and vein
    pR(temp.xy, t/PI);

    // rotate
    pR(pos.xz, 3. * PI / 6.);

    // left-right tilt, up-down tilt
    pR(pos.xz, -PI/12.*cos(t/PI)); pR(pos.yz, PI/16.*sin(t/PI));

    // render blood vein and cells
    return opU(
      opU(
        vessel(pos, 0.),
        bloodVein(temp)
      ),
      bloodCellField(temp)
    );
  }

  // SCENE 5: Nanobot approaches virus
  else if ((t -= 19.2) < 0.) {
    pR(pos.xy, -.4);
    pR(pos.xz, t / 20. - .8);
    pos += vec3(sin(t / 6. - 1.), .5, 2. + sin(t / 6. - 1.));

    temp = pos;

    pR(temp.xy, -.1);
    res = bloodCellField(temp - vec3(8., 2., 5.));

    res = opBlend(
      res,
      heart(pos, 0.),
      20.
    );
    res = opBlend(
      res,
      virus(pos + .5, 1.),
      50.
    );

    // rotate
    pR(pos.xy, PI / 14.); pR(pos.xz, PI / 20.);

    // left-right tilt, up-down tilt
    //pR(pos.xz, -PI/12.*cos(t/PI)); pR(pos.yz, PI/16.*sin(t/PI));

    pos -= vec3(
      8. + sin(t / 10. - 1.5) * 7.,
      //- 3. * sin(min(t, (PI - 1. ) * 8.) / 8.),
      0.,
      .5
    );

    return opBlend(
      res,
      vessel(pos, 0.
      ),
      30.
    );
  }

  // SCENE 6: Nanobot attacks virus
  else if ((t -= 19.2) < 0.) {
    t += 19.2; // TODO;
    pR(pos.yz, .7);
    pR(pos.xz, -3.);
    pos += vec3(t / 16. - .5,1.,-1.);

    res = opBlend(
      heart(pos, max(0., (t - 2.) / 20.)),
      virus(pos + vec3(.5), 1. / (1. + t / 10.)),
      50.
    );

    // rotate
    pR(pos.xy, PI / 8.); pR(pos.xz, PI / 6.);

    // left-right tilt, up-down tilt
    pR(pos.xz, -PI/12.*cos(t/PI)); pR(pos.yz, PI/16.*sin(t/PI));

    return opBlend(
      res,
      vessel(pos - vec3(1., 0., -.2), 1.),
      15.
    );
  }

  // SCENE 7: Nanobot retracts
  else {

    pR(pos.xy, 1.);
    pos += vec3(sin(t / 8.), 1., -sin(-2. + t / 8.));

    // rotate
    pR(temp.xz, PI / 2.);

    return opBlend(
      heart(pos, 1.),
      vessel(temp - vec3(5. - t, -.5, 1.), 0.),
      15.
    );
  }
}

void main() {
  vec3 ro = vec3(0.,0.,1.),
       tot = vec3(0.),
       col = vec3(0.),
       pos;

  vec4 res; // = vec3(-1.);
  float t = 0.; // tmin

  // ray direction
  vec3 rd =
    // camera-to-world transformation
    mat3(ro.zxx, ro.xzx, -ro) *

    normalize(
      vec3(
        // pixel coordinates
        (2. * gl_FragCoord.xy - a.xy) / a.y,
        2.
      )
    );

  for(float i = 0.; i < 64.; i++) // 64. = maxIterations
    t += (res = map(pos = ro + rd * t)).x;

  vec2 e = vec2(.01, -.01);

  vec3 nor = normalize(
    e.xyy * map(pos + e.xyy).x
    + e.yyx * map(pos + e.yyx).x
    + e.yxy * map(pos + e.yxy).x
    + e.xxx * map(pos + e.xxx).x // this last one could be deleted out without ruining the demo too much?
  ),
  ref = reflect(rd, nor),

  lig = vec3(.7); // direction of light

  // material
  float amb = nor.y,
        dif = max(dot(nor, lig), 0.),
        //dom = smoothstep(-.1, .1, ref.y),
        // dom = ref.y,
        fre = pow(min(dot(nor, rd) + 1., 1.), 2.),
        spe = pow(dot(ref, lig), 2.);

  if(length(res.yzw) > 0.)
    col = res.yzw * (
      dif
        + spe * dif
        + pow(.4 * amb, 2.)
        + pow(.2 * ref.y, 4.)
        + .5 * fre
    );

  tot = pow(
    // fog
    mix(col, vec3(.03, .04, .05), 1. - exp(-.001 * t * t * t)),

  	// gamma
    vec3(.6, .5, .4)
  )

  // fade in
  * pow(min((a.z - 1.) / 8., 1.), 2.)
  // fade out
  * pow(clamp((135. - a.z) / 8., 0., 1.), 2.); // 135. = demo length in seconds

  gl_FragColor = vec4(tot, 1.); // 4 = AA * AA
}
