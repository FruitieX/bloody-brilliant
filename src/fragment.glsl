precision highp float;

// a.xy = resolution
// a.z = time (s)
// a.w = bass
uniform vec4 a;

float PI = 3.14;

vec4 opBlend( vec4 d1, vec4 d2, float k ) {
  float h = clamp( .5+.5*(d2.x-d1.x)/k, 0., 1. );
  h = mix(d2.x,d1.x,h) - k*h*(1.-h);
  return vec4(h,
    (d1.yzw * d2.x + d2.yzw * d1.x) / (d1.x + d2.x)
  );
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
    // torus
    vec4(length(vec2(length(p.xz)-.3,p.y)) - .1),
    // capped cylinder
    vec4(clamp(d.x, d.y, 0.) + length(max(d,0.))),
    .1
  ).x;
}

float sdTriPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x+.5*p.y, -p.y)-h.x*.5);
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
  pR(pos.zx, .2 * a.z + .1 * a.w); // give speed to blood wall
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
    1, .1, .1
  );
}

vec4 bloodVein(vec3 p, float colorMod) {
  vec3 temp = p;
  p += vec3(14, 0, 1.5);

  return opBlend(
    // bloodVein
    vec4(
      // tunnel shape
      // the first constant sets size of torus
      // second sets size of middle
      3. -length(vec2(length(p.xz)-14.,p.y))

      // blobby surface
      - .05 * (1. - sin(3. * (p.z - 2. * a.z)))

      + 2. * a.w,

      // color
      colorMod, .1 * colorMod, .1 * colorMod
    ),
    bloodCellField(temp),
    .1
  );
}

vec4 virus(vec3 pos, float size) {
  vec3 temp = pos;

  pModPolar(pos.yz, 7.);
  pModPolar(pos.yx, 7.);
  pos.y -= .5 * size;

  return opBlend(
    // blob
    vec4(
      length(temp) - .5 * size - a.w / 5.,
      0, 1, 0
    ),
    // spikes
    vec4(
      fCapsule(
        pos,
        .01 * size,
        .4 * size
      ),
      1, .6, 1
    ),
    .2
  );
}

vec4 heart(vec3 p, float virusSize, float colorMod) {
  vec3 temp = p;

  temp.x -= 6.;
  pModPolar(temp.yz, 7.);
  pR(temp.xy, 1.);

  vec3 temp2 = p - vec3(8, 0, 5);
  pR(temp2.yz, .2);

  return opBlend(
    opBlend(
      virus(p - .4 * a.w, virusSize),
      // heart
      vec4(
        opBlend(
          vec4(
            // tunnel shape
            sin(p.x) + sin(p.y) + sin(p.z)

            // wow interesting
            //(.2 - a.w * .1) * length(sin(p))

            // blobby surface
            //+ (.1 - a.w * .4) * sin(p.x) * sin(p.y) * sin(p.z)

            // heartbeat
            - a.w
          ),
          // muscle tissue stuff
          vec4(
            fCapsule(temp, .1, 9.)
          ),
          .5
        ).x,
        // color
        colorMod, .2 * colorMod, .1 * colorMod
      ),
      .1
    ),
    bloodCellField(temp2),
    .1
  );
}

vec4 vessel(vec3 pos, float laser) {
  vec3 col = vec3(.1);

  pR(pos.xy, PI/2.);
  vec4 res = vec4(sdTriPrism(pos , vec2(.25,.15)), col), temp;
  pR(pos.xz, PI/2.);
  pR(pos.zy, PI/2.);
  // inline opI
  temp = vec4(sdTriPrism(pos, vec2(.15,.25)), col);
  res = (res.x > temp.x ? res : temp);

  pos.z += .3;
  res = opBlend(res, vec4(sdTriPrism(pos, vec2(.15,.2)), col), .0);

  pR(pos.yz, PI/2.);
  res = opBlend(res, vec4(sdTriPrism(pos , vec2(.4,.01)), col), .0);
  pR(pos.xz, PI/2.);
  pos.xy += .1;
  res = opBlend(res, vec4(sdTriPrism(pos , vec2(.2,.01)), col), .0);

  if (laser > 0.) {
    // TODO: pos += vec3(.1, 2.3, -.15) ?
    res = opBlend(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2, -.1), .01, 2.) / 3.,
        10, .2, .3
      ),
    .05
    );

    pos.z -= .2;

    res = opBlend(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2, -.1), .01, 2.) / 3.,
        10, .2, .3
      ),
      .05
    );
  }

  return res;
}

vec4 map(vec3 heartPos) {
  float t = a.z,
        colorMod = 1.,
        laser = 0.,
        scene = 0.,
        virusSize = 0.;

  vec3 bloodVeinPos = heartPos,
       vesselPos = heartPos;

  // SCENE 1: Inside heart
  if ((t -= 19.2) < 0.) {
    pR(heartPos.xz, t / 6.); pR(heartPos.xy, t / 5.);
    heartPos += 1.;
    vesselPos += 9.;
  }

  // SCENE 2: Nanobot in blood vein
  else

  if ((t -= 19.2) < 0.) {
    // select blood vessel scene
    scene = 1.;
  }

  // SCENE 3: Virus in heart
  else

  if ((t -= 19.2) < 0.) {
    colorMod = -t / 10.;
    virusSize = 1.;

    virusSize = 1.;
    pR(heartPos.yz, 1.);
    pR(heartPos.xy, t/10.);

    heartPos += 1. - t / 10.;
    vesselPos += 9.;
  }

  // SCENE 4: Nanobot in blood vein, nearing heart
  else

  if ((t -= 19.2) < 0.) {
    // darken over time
    colorMod = -t / 10.;

    // select blood vessel scene
    scene = 1.;
  }

  // SCENE 5: Nanobot approaches virus
  else

  if ((t -= 19.2) < 0.) {
    colorMod = 0.;
    virusSize = 1.;

    pR(heartPos.xz, t / 40. - .8);
    heartPos += vec3(sin(t / 6. - 1.), 1, 2. + sin(t / 6. - 1.));

    vesselPos = heartPos - vec3(
      8. + sin(t / 10. - 1.5) * 8.,
      1.5,
      1
    );
  }

  // SCENE 6: Nanobot attacks virus
  else

  if ((t -= 19.2) < 0.) {
    colorMod = max(0., (t + 10.) / 20.);
    virusSize = 1. - (t + 20.) / 20.;

    pR(heartPos.yz, .7);
    vesselPos = heartPos += 2. + t / 20.;

    vesselPos.x += sqrt((t + 20.) / 10.) - 2.;

    laser = cos(2. + t / 4.);
  }

  // SCENE 7: Nanobot retracts
  else

  {
    heartPos += 2. - t / 10.;
    vesselPos = heartPos;

    // rotate
    pR(vesselPos.xz, PI / 2.);

    vesselPos += vec3(t - 5., -1, 1);
  }

  // move vessel forward (only in scene 1)
  vesselPos += scene * vec3(0, .25, .5);
  // rotate vessel (only in scene 1)
  pR(vesselPos.xz, scene * PI / 2.);

  // rotation to blood cells and vein
  pR(bloodVeinPos.xy, t/PI);

  // left-right tilt, up-down tilt
  pR(vesselPos.xz, -PI/12.*cos(t/PI)); pR(vesselPos.yz, PI/16.*sin(t/PI));

  //virus(heartPos - .4 * a.w, virusSize),
  return opBlend(
    // heart & virus
    scene == 0. ? heart(heartPos, virusSize, colorMod) : bloodVein(bloodVeinPos, colorMod),
    vessel(vesselPos, laser),
    .1 + laser > 0. ? .2 : 0.
  );
}

void main() {
  vec3 ro = vec3(0,0,1),
       tot = vec3(0),
       col = vec3(0),
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
        2
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
    mix(col, vec3(.05), 1. - exp(-.001 * t * t * t)),

  	// gamma
    vec3(.6, .5, .4)
  )

  // fade in
  * pow(min((a.z - 1.) / 8., 1.), 2.)
  // fade out
  * pow(clamp((135. - a.z) / 8., 0., 1.), 2.); // 135. = demo length in seconds

  // vignette
  //* pow(1. - .001 * length((2. * gl_FragCoord.xy - a.xy)), 2.);

  gl_FragColor = vec4(tot, 1); // 4 = AA * AA
}
