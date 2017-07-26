precision highp float;

// a.xy = resolution
// a.z = time (s)
// a.w = bass
uniform vec4 a;

float PI = 3.14;

float smin( float a, float b, float k ) {
  return -log(exp( -k*a ) + exp( -k*b ))/k;
}

vec4 opI( vec4 d1, vec4 d2 ) {
  return d1.x < d2.x ? d2 : d1;
}

vec4 opBlend( vec4 d1, vec4 d2, float k ) {
  return vec4(
    smin( d1.x, d2.x, k ),
    (d1.yzw * d2.x + d2.yzw * d1.x) / (d1.x + d2.x)
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

vec4 heart(vec3 p) {
  return vec4(
    // tunnel shape
    (1. - a.w * .5) * (cos(p.x) + sin(p.y) + sin(p.z)) / 5.

    // blobby surface
    + (1. - a.w * 2.) * .05 * sin(10. * p.x) * sin(10. * p.y) * sin(10. * p.z) * sin(length(sin(sin(p * 2.) + a.z / 10.)) + .5),

    // color
    sin(vec3(1., .2, .1) * (length(sin(sin(p * 2.) + a.z / 10.)) + .5))
  );
}

float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2.*PI/repetitions,
      	a = mod(atan(p.y, p.x) + angle/2., angle) - angle/2.,
      	c = floor(a/angle);
	p = vec2(cos(a), sin(a))*length(p);
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2.)) c = abs(c);
	return c;
}

vec4 bloodCellField(vec3 pos) {
  // set up the correct rotation axis
  pos.x += 15.; // move rotational origo to center of blood vein
  pR(pos.xz, -(4. * a.z + 2. * a.w) / 20.); // give speed to blood wall
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
  pos.x -= 2.5;

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
    sin(vec3(1., .1, .1) * (length(sin(sin(p * 2.) + a.z / 10.)) + .5))
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
      .01 * size,
      size
    ), 1., .6, 1.);

  pR(pos.xy, PI/4.);

  spikes = opU(
    spikes,
    vec4(fCapsule(
      pos,
      .01 * size,
      size
    ), 1., .6, 1.)
  );

  pR(pos.xy, PI/4.);

  spikes = opU(
    spikes,
    vec4(fCapsule(
      pos,
      .01 * size,
      size
    ), 1., .6, 1.)
  );

  pR(pos.xy, PI/4.);

  spikes = opU(
    spikes,
    vec4(fCapsule(
      pos,
      .01 * size,
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
  // pos += vec3(.1, .1, 0.);
  pos.x += .1;
  pos.y += .1;
  res = opU(res, vec4(sdTriPrism(pos , vec2(.2,.01)), col));

  if (laser > 0.) {
    // TODO: pos += vec3(.1, 2.3, -.15) ?
    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2.3, -.15), .01, 2.),
        100., .2, .3
      )
    );

    pos.z -= .3;

    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2.3, -.15), .01, 2.),
        100., .2, .3
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
  if ((t -= 16.) < 0.) {
    pos.z -= 1.; pR(pos.xz, t / 6.); pR(pos.xy, t / 5.);

    return heart(pos);
  }

  // SCENE 2: Nanobot in blood vein
  else if ((t -= 16.) < 0.) {
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
  else if ((t -= 16.) < 0.) {
    pR(pos.yz, 7.);
    pR(pos.xy, t/20.);
    pos += vec3(1.);
    return opBlend(
      heart(pos),
      virus(pos + vec3(.5), 1.),
      50.
    );
  }

  // SCENE 4: Nanobot in blood vein, TODO: viruses on walls?
  else if ((t -= 16.) < 0.) {
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
  else if ((t -= 16.) < 0.) {
    t += 16.; // TODO;
    pR(pos.xy, -.4);
    pR(pos.xz, -.8 + t / 32.);
    pos += vec3(cos(t / 6.), 0.5, 2.5 + cos(t / 6.));

    res = opBlend(
      virus(pos + vec3(.5), 1.),
      heart(pos),
      50.
    );

    // rotate
    pR(pos.xy, PI / 8.); pR(pos.xz, PI / 6.);

    // left-right tilt, up-down tilt
    pR(pos.xz, -PI/12.*cos(t/PI)); pR(pos.yz, PI/16.*sin(t/PI));

    return opBlend(
      res,
      vessel(pos - vec3(
        2.5 + 1.5 * cos(1. + min(t, (PI - 1. ) * 8.) / 8.),
        0.,
        .5
        ), 0.
      ),
      30.
    );
  }

  // SCENE 6: Nanobot attacks virus
  else if ((t -= 16.) < 0.) {
    t += 16.; // TODO;
    pR(pos.yz, .7);
    pR(pos.xz, -3.);
    pos += vec3(t / 16. - .5,1.,-1.);

    res = opBlend(
      virus(pos + vec3(.5), 1. / (1. + t / 10.)),
      heart(pos),
      50.
    );

    // rotate
    pR(pos.xy, PI / 8.); pR(pos.xz, PI / 6.);

    // left-right tilt, up-down tilt
    pR(pos.xz, -PI/12.*cos(t/PI)); pR(pos.yz, PI/16.*sin(t/PI));

    return opBlend(
      res,
      vessel(pos - vec3(1., 0., -.2), max(0., t - 2.)),
      15.
    );
  }

  // SCENE 7: Nanobot retracts
  else if ((t -= 16.) < 0.) {
    pR(pos.yz, .7);
    pR(pos.xz, -3.);
    pos += vec3(t / 16. - .5,1.,-1.);

    res = opBlend(
      virus(pos + vec3(.5), 1. / (16. + t / 10.)),
      heart(pos),
      50.
    );

    // rotate
    pR(pos.xy, PI / 8.); pR(pos.xz, PI / 6.);

    // left-right tilt, up-down tilt
    pR(pos.xz, -PI/12.*cos(t/PI)); pR(pos.yz, PI/16.*sin(t/PI));

    return opBlend(
      res,
      vessel(pos - vec3(1., 0., -.2), 0.),
      15.
    );
  }

  // SCENE 8: Closing shot of heart
  else if ((t -= 16.) < 0.) {
    pos.z -= 1.; pR(pos.xz, t / 6.); pR(pos.xy, t / 5.);

    return heart(pos);
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
    )

    // fade in
    * pow(clamp(-(1. - a.z) / 8., 0., 1.), 2.)
    // fade out
    * pow(clamp((120. - a.z) / 8., 0., 1.), 2.); // 120. = demo length in seconds
  }

  gl_FragColor = vec4(tot / 4., 1.); // 4 = AA * AA
}
