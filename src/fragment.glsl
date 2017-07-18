precision highp float;

// a.xy = resolution
// a.z = time (s)
// a.w = unused
uniform vec4 a;

// b.x = bass
// b.y = accumulated bass
// b.z = unused
// b.w = unused
uniform vec4 b;

float PI = 3.14;

float calcPlasma(float x, float y, float z, float t) {
  // horizontal sinusoid
  //float sine1 = sin(x * 10. + t * 2.);

  // rotating sinusoid
  //float sine2 = sin(10. * (x * sin(t / 2.) + z * cos(t / 3.)) + t);

  // circular sinusoid
  float cx = x + sin(t / 5.);
  float cy = y + cos(t / 3.);
  float blend = sin(sqrt(100. * (cx * cx + cy * cy) + 1.) + t);

  //float blend = sine1 + sine2 + sine3;
  //float blend = sine3;

  //blend *= 1.0 + sin(t / 4.0) * 2.0;
  //blend *= 3.0;
  blend = sin(blend * 2.) / 2. + .5;
  //blend = pow(blend, 2.0);

  return blend;
}

float smin( float a, float b, float k ) {
  return -log(exp( -k*a ) + exp( -k*b ))/k;
}

/*
float opS_1(float d1, float d2) {
  return max(-d2,d1);
}
*/

// TODO: test me
/*
vec4 opS(vec4 d1, vec4 d2) {
  return (d1.x<-d2.x) ? d2 : d1;
}
*/

vec4 opI( vec4 d1, vec4 d2 ) {
    return (d1.x < d2.x) ? d2 : d1;
}

// TODO: remove all _1 functions (take in float instead of vec2)
/*
float opBlend_1( float d1, float d2, float k ) {
    return smin( d1, d2, k );
}
*/

vec4 opBlend( vec4 d1, vec4 d2, float k ) {
  float tot = d1.x + d2.x;

  return vec4(
    smin( d1.x, d2.x, k ),
    1. / tot * (d1.yzw * (tot - d1.x) + d2.yzw * (tot - d2.x))
  );
}

// t = time to start transition
// tt = transition length
/*
vec2 opMorph( vec2 d1, vec2 d2, float t, float tt ) {
  float k = (a - t) / tt;

  //k = min(1., k);
  //k = max(0., k);

  k = clamp(0., k, 1.);

  return vec2(
    d1.x * (1. - k) + d2.x * k,
    d1.y * (1. - k) + d2.y * k
  );
}
*/

vec4 opU(vec4 d1, vec4 d2) {
  return (d1.x<d2.x) ? d1 : d2;
}

/*
vec3 opRep(vec3 p, vec3 c) {
  return mod(p,c)-.5*c;
}
*/

/*
vec3 opTwist(vec3 p) {
  float  c = cos(p.y);
  float  s = sin(p.y);
  mat2   m = mat2(c,-s,s,c);
  return vec3(m*p.xz,p.y);
}
*/

// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

/*
vec2 pRvec(inout vec2 p, float a) {
	return cos(a)*p + sin(a)*vec2(p.y, -p.x);
}
*/

float fCapsule(vec3 p, float r, float c) {
	return mix(length(p.xz) - r, length(vec3(p.x, abs(p.y) - c, p.z)) - r, step(c, abs(p.y)));
}

float sdSphere(vec3 p, float s) {
  return length(p)-s;
}

float sdBloodCell(vec3 p) {
  float d1 = length(vec2(length(p.xz)-.3,p.y)) - .1;
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(.3,.06);
  float d2 = min(max(d.x,d.y),0.) + length(max(d,0.));

  return (smin(d1,d2,32.)

  // // large bumpiness
  // + .005 * sin(20. * p.x) * sin(20. * p.y) * sin(20. * p.z)
  //
  // // smaller bumpiness
  // + .0005 * sin(50. * p.x) * sin(50. * p.y) * sin(50. * p.z)
  );

}

float sdTorus(vec3 p) {
  // the first constant sets size of torus
  // second sets size of middle
  return -(length(vec2(length(p.xz)-14.,p.y)) - 3.);
}

float sdTriPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float sdHexPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max((q.x*0.866025+q.y*0.5),q.y)-h.x);
}

vec4 heart(vec3 p) {
  float plasma1 = calcPlasma(p.x, p.y, p.z, a.z / 10.) + .5;

  return vec4(
    // tunnel shape
    (1. - b.x * .25) * (cos(p.x) + sin(p.y) + sin(p.z)) / 5.

    // blobby surface
    + (1. - b.x) * .05 * sin(10. * p.x) * sin(10. * p.y) * sin(10. * p.z) * sin(plasma1),

    // color
    sin(vec3(1., .2, .1) * plasma1)
  );
}

float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2.*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2.)) c = abs(c);
	return c;
}

/*
vec4 bloodCellWall(vec3 p) {
  p.z += .2;
  // vec3 p = pos;// - vec3(1.,0.,0.);

  vec3 col = vec3(1., .1, .1);

  vec3 rotated = p - vec3(1.,-1.,0.);
  pR(rotated.yz, a.z / 6.);
  vec4 res = vec4(sdBloodCell(rotated), col);

  // repeat
  rotated = p + vec3(0.,2.,0.);
  pR(rotated.xy, a.z / 6.);
  res = opU(res, vec4(sdBloodCell(rotated.yxz), col));

  // repeat
  rotated = p + vec3(2.,1.,.5);
  pR(rotated.yz, a.z / 7.);
  res = opU(res, vec4(sdBloodCell(rotated.yzx), col));

  // repeat
  rotated = p + vec3(1.,-1.5,1.);
  pR(rotated.xy, a.z / 6.);
  res = opU(res, vec4(sdBloodCell(rotated), col));

  // repeat
  rotated = p + vec3(2.,-1.,0.);
  pR(rotated.xz, a.z / 6.);
  res = opU(res, vec4(sdBloodCell(rotated.xzy), col));

  // repeat
  rotated = p - vec3(.8,1.,0.);
  pR(rotated.xy, a.z / 7.);
  res = opU(res, vec4(sdBloodCell(rotated.yxz), col));

  return res;
}
*/

vec4 bloodCellField(vec3 p, float v) {
  // set up the correct rotation axis
  p.z += 3.;
  p.x += 15.; // move rotational origo to center of blood vein
  pR(p.xz, -(a.z * v + b.y) / 20.); // give speed to blood wall
  pModPolar(p.xz, 24.); // Rotate and duplicate blood wall around torus origo
  p -= vec3(15.,0.,0.);

  //p.z += .2;
  // vec3 p = pos;// - vec3(1.,0.,0.);

  vec3 col = vec3(1., .1, .1);

  vec3 rotated = p - vec3(1.,-1.,0.);
  pR(rotated.yz, a.z / 6.);
  vec4 res = vec4(sdBloodCell(rotated), col);

  // repeat
  rotated = p + vec3(0.,2.,0.);
  pR(rotated.xy, a.z / 6.);
  res = opU(res, vec4(sdBloodCell(rotated.yxz), col));

  // repeat
  rotated = p + vec3(2.,1.,.5);
  pR(rotated.yz, a.z / 7.);
  res = opU(res, vec4(sdBloodCell(rotated.yzx), col));

  // repeat
  rotated = p + vec3(1.,-1.5,1.);
  pR(rotated.xy, a.z / 6.);
  res = opU(res, vec4(sdBloodCell(rotated), col));

  // repeat
  rotated = p + vec3(2.,-1.,0.);
  pR(rotated.xz, a.z / 6.);
  res = opU(res, vec4(sdBloodCell(rotated.xzy), col));

  // repeat
  rotated = p - vec3(.8,1.,0.);
  pR(rotated.xy, a.z / 7.);
  res = opU(res, vec4(sdBloodCell(rotated.yxz), col));

  return res;
}

vec4 bloodVein(vec3 p,float v) {
  float plasma1 = calcPlasma(p.x / 8., p.y / 8., p.z / 8., a.z / 10.);

  // rotate
  // pR(p.xy, a/5.);
  return vec4(
    // tunnel shape
    sdTorus(p + vec3(14.,0.,1.5))

    // blobby surface
    - 0.05 * (1. + sin(3. * (p.z + a.z*v))),

    // color
    sin(vec3(1., .1, .1) * (plasma1 / 2. + .5))
  );
}

vec4 virus(vec3 pos, float size) {
  // velocity
  pR(pos.xy, PI/4.);

  float scale = 1. + b.x / 10.;
  scale *= size;
  float spikeLen = 1.*scale;
  float spikeThickness = 0.01*scale;
  float blend = 9.;

  vec4 res = vec4(sdSphere(pos, .5*scale), 0., 1., 0.);

  pModPolar(pos.yz, 7.);

  vec4 spikes = vec4(fCapsule(pos, spikeThickness, spikeLen), 1., .6, 1.);

  pR(pos.xy, PI/4.);

  spikes = opU(
    spikes,
    vec4(fCapsule(pos, spikeThickness, spikeLen), 1., .6, 1.)
  );

  pR(pos.xy, PI/4.);

  spikes = opU(
    spikes,
    vec4(fCapsule(pos, spikeThickness, spikeLen), 1., .6, 1.)
  );

  pR(pos.xy, PI/4.);

  spikes = opU(
    spikes,
    vec4(fCapsule(pos, spikeThickness, spikeLen), 1., .6, 1.)
  );

  res = opBlend(
    res,
    spikes,
    blend
  );

  return res;
}

/*
float udBox( vec3 p, vec3 b ) {
  return length(max(abs(p)-b,0.));
}
*/

/*
float sdTorus2(vec3 p) {
  // the first constant sets size of torus
  // second sets size of middle
  return length(vec2(length(p.xz)-.5,p.y)) - 0.1;
}
*/

/*
vec4 sdArm(vec3 p, float len_arm, float angle) {
  vec4 res = vec4(fCapsule(p, .05,len_arm), .1,.1,.1);
  p.y += len_arm;
  pR(p.xy, angle);
  p.y += len_arm;
  res = opU(res, vec4(fCapsule(p, .05,len_arm), .1,.1,.1));
  return res;
}
*/

vec4 vessel(vec3 pos, bool laser) {
  float s = 2.; // scale
  vec3 col = vec3(.1);

  pR(pos.xy, PI/2.);
  vec4 res = vec4(sdTriPrism(pos , vec2(.5,.3)/s), col);
  pR(pos.xz, PI/2.);
  res = opI(res, vec4(sdTriPrism(pos , vec2(.7)/s), col));
  pR(pos.zy, PI/2.);
  res = opI(res, vec4(sdHexPrism(pos, vec2(.3,.5)/s), col));
  pos.z += .3;
  res = opU(res, vec4(sdHexPrism(pos, vec2(.3,.4)/s), col));

  pR(pos.yz, PI/2.);
  res = opU(res, vec4(sdTriPrism(pos , vec2(.8,.01)/s), col));
  pR(pos.xz, PI/2.);
  pos.x += .1;
  pos.y += .1;
  res = opU(res, vec4(sdTriPrism(pos , vec2(.39,.01)/s), col));

  // arms
  // pos = origPos;
  // pos.x += .3;
  // pR(pos.xy, PI/2.);
  // pR(pos.yz, PI);
  // // pos.z += .3;
  // pR(pos.yz, -PI/8.);
  // pos.z -= .4;
  // pR(pos.xz, PI/2.);
  // res = opU(res, sdArm(pos, .2, -PI/8.));
  // pR(pos.yz, PI/4.);
  // res = opU(res, sdArm(pos + vec3(.0,.0,.3), .3, -PI/8. * a));
  // res = vec4(fCapsule(pos, .03,.5), .1,.1,.1);
  // pos.y += .5;
  // pR(pos.xy, PI/8.);
  // pos.y += .5;
  // res = opU(res, vec4(fCapsule(pos, .03,.5), .1,.1,.1));

  // propeller thing
  // pos = origPos;
  // pR(pos.yz, a * 10.);
  // pModPolar(pos.yz, 3.);
  // res = opU(
  //   res,
  //   vec4(
  //     fCapsule(pos - vec3(.93, 0., 0.), 0.03, 0.3),
  //     .4, .3, .7
  //   )
  // );

  if (laser) {
    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2.3, -.15), .01 + .005 * sin(10. * pos.y + 20. * a.z), 2.),
        vec3(abs(sin(a.z * 10. + pos.y * 10.)), .2, .3)
      )
    );

    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.1, 2.3, .15), .01 + .005 * sin(10. * pos.y + 20. * a.z), 2.),
        vec3(abs(sin(a.z * 10. + pos.y * 10.)), .3, .1)
      )
    );
  }

  return res;
}

// Scene list
// Scene 0 = Intro, Normal day at blood work
// Scene 1 = Virus drives past camera, makes everything funky color
// scene 2 = Blood canal chase begins
// scene 3 = Final destination in my heart. Virus dies. Boss fight?
// scene 4 = Greetings

// SCENES
/*
vec4 scene0(vec3 pos, float t) {
  vec4 res = vec4(sdSphere(pos,.01),1.,0.,0.);

  res = opU(res, bloodVein(pos, 2.));
  res = opU(res, bloodCellField(pos, 2.));
  return res;
}
*/

vec4 scene1(vec3 pos, float t) {
  //vec4 res = vec4(sdSphere(pos,.01),1.,0.,0.);

  float T = PI; // period
  //vec3 pos_vessel = pos + vec3(0.,0.,1.);
  //pR(pos_vessel.xz, PI/2.);
  vec3 p_vessel = pos + vec3(.1-.2 * sin(t/T),.6 + .2 * cos(t/T),1.);
  // left-right tilt
  pR(p_vessel.xz, PI/2.-PI/12.*cos(t/T));
  // up-down tilt
  pR(p_vessel.yz, -PI/16.*sin(t/T));
  vec4 res = vessel(p_vessel, false);

  // rotation to blood cells and vein
  pR(pos.xy, t/T);
  // render blood vein and cells
  res = opU(res, bloodVein(pos, -2.));
  res = opU(res, bloodCellField(pos, -2.));

  return res;
}

/*
vec4 scene2(vec3 pos, float t) {
  vec4 res = vec4(sdSphere(pos,.01),1.,0.,0.);

  res = opU(res, bloodVein(pos, -2.));
  res = opU(res, bloodCellField(pos, -2.));


  // res = opU(
  //   res,
  //   virus(
  //     vec3(pos.x+cos(t),pos.y+sin(t),pos.z+sin(t*.2)*3.),
  //     cos(t/2.)
  //   )
  // );

  return res;
}
*/


vec4 scene3(vec3 pos, float t) {
  // pos += vec3(0., 1., -4.);

  //pos += vec3(sin(t / 8.) / 4.,1.,1.);
  pR(pos.yz, 7.);
  pR(pos.xy, t/20.);
  pos += vec3(1., 1., 1.);
  return opBlend(
    heart(pos),
    virus(pos + vec3(.5), 1.),
    50.
  );
}

vec4 scene4(vec3 pos, float t) {

  //pR(pos.xz, t / 2.);
  pR(pos.xy, -.4);
  pR(pos.xz, -.8 + t / 32.);
  pos += vec3(cos(t / 6.), 0.5, 2.5 + cos(t / 6.));
  //pR(pos.zy, t);
  // vessel
  vec4 res = opBlend(
    heart(pos),
    virus(pos + vec3(.5), 1.),
    50.
  );

  //pR(pos.yz, sin(t / 4.) / 8.);
  pR(pos.xz, PI / 6.);
  pR(pos.xy, PI / 8.);

  // left-right tilt
  pR(pos.xz, +PI/12.*cos(t/PI));
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
    virus(pos + vec3(.5), 1.5 / (1. + t / 10.)),
    50.
  );

  pR(pos.xz, PI / 6.);
  pR(pos.xy, PI / 8.);

  // left-right tilt
  pR(pos.xz, -PI/12.*cos(t/PI));
  // up-down tilt
  pR(pos.yz, -PI/16.*sin(t/PI));
  return opBlend(
    res,
    vessel(pos - vec3(1., 0., -.2), t > 2.),
    15.
  );
}

vec4 map(vec3 pos, vec3 origin) {
  float t = a.z;
  /* ---------- DEBUGGING ---------- */
  // Uncomment when debugging single scene
  // return scene4(pos, a.z);

  /* ---------- SCENES --------- */
  if ((t -= 22.5) < 0.) {
    // nanobot
    return scene1(pos, t);
  } else if ((t -= 11.) < 0.) {
    // virus
    return scene3(pos, t + 10.);
  } else if ((t -= 11.5) < 0.) {
    // nanobot, TODO: viruses on blood vein walls?
    return scene1(pos, t);
  } else if ((t -= 15.) < 0.) {
    // nanobot approaches virus
    return scene4(pos, t + 15.);
  } else if ((t -= 25.) < 0.) {
    // nanobot fires lasers
    return scene4_1(pos, t + 25.);
  } else {
    return vec4(0.);
  }
}

void main() {

  vec3 tot = vec3(0.);
  for( float m=0.; m<2.; m++ )   // 2x AA
  for( float n=0.; n<2.; n++ ) { // 2x AA
    // camera
    // ro = ray origin = where the camera is
    // ta = camera direction (point which the camera is looking at)
    // cr = camera rotation

    // rotating camera
    vec3 pos = vec3(
      cos(a.z/2.),
      sin(a.z/2.),
      sin(a.z/2.)/2.+.5
    );
    // vec3 ro = pos.xzy*2.;
    // static camera
    vec3 ro = vec3(0.,0.,1.);

    // ray direction
    vec3 rd =
      // camera-to-world transformation
      mat3(ro.zxx,ro.xzx,-ro) *

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

    vec3 col = vec3(.03, .04, .05);
    float t = .02; // tmin
    vec4 res; // = vec3(-1.);

    for( float i=0.; i<64.; i++ ) // 64. = maxIterations
      t += (res = map( ro+rd*t, ro )).x;

    vec2 e = vec2(1e-4, -1e-4);
    if( length(res.yzw)>0. ) {
      vec3 pos = ro + t*rd;

      vec3 nor = normalize(e.xyy*map(pos+e.xyy,pos).x
                           + e.yyx*map(pos+e.yyx,pos).x
                           + e.yxy*map(pos+e.yxy,pos).x
                           + e.xxx*map(pos+e.xxx,pos).x);
      vec3 ref = reflect( rd, nor );

      // material
      vec3  lig = normalize( vec3(.4, .7, .6) );
      float amb = clamp( .5+.5*nor.y, 0., 1. );
      float dif = clamp( dot( nor, lig ), 0., 1. );
      float dom = smoothstep( -.1, .1, ref.y );
      float fre = pow( clamp(1.+dot(nor,rd),0.,1.), 2. );
      float spe = pow(clamp( dot( ref, lig ), 0., 1. ),2.);

      vec3 lin = vec3(0.);
      lin += dif;
      lin += spe*dif;
      lin += pow(.4*amb/**occ*/, 2.);
      lin += pow(.2*dom/**occ*/, 4.);
      lin += .5*fre/**occ*/;
      col = res.yzw*lin;

      // fog
      col = mix( col, vec3(.03, .04, .05), 1.-exp( -.001*t*t*t ) );
    }


    tot += pow(
      col,

    	// gamma
      vec3(.6, .5, .4)
    );
  }

  gl_FragColor = vec4( tot / 4., 1. ); // 4 = AA * AA
}
