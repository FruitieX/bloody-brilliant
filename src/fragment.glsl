precision highp float;

// time variable (seconds)
uniform float a;
// resolution (1920.0, 1080.0)
uniform vec2 b;

// bass
uniform float c;
// treble
uniform float d;
// accumulated bass
uniform float e;
// frequency of lead synth
uniform float f;

float PI = 3.14;

float displacement = .0;

float calcPlasma(float x, float y, float z, float t) {
  // horizontal sinusoid
  float sine1 = sin(x * 10. + t * 2.);

  // rotating sinusoid
  float sine2 = sin(10. * (x * sin(t / 2.) + z * cos(t / 3.)) + t);

  // circular sinusoid
  float cx = x + .5 * sin(t / 5.);
  float cy = y + .5 * cos(t / 3.);
  float sine3 = sin(sqrt(100. * (cx * cx + cy * cy) + 1.) + t);

  float blend = sine1 + sine2 + sine3;

  //blend *= 1.0 + sin(t / 4.0) * 2.0;
  //blend *= 3.0;
  blend = sin(blend * PI / 2.) / 2. + .5;
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
vec4 opS(vec4 d1, vec4 d2) {
  return (d1.x<-d2.x) ? d2 : d1;
}

vec4 opI( vec4 d1, vec4 d2 ) {
    return (d1.x < d2.x) ? d2 : d1;
}

// TODO: remove all _1 functions (take in float instead of vec2)
float opBlend_1( float d1, float d2, float k ) {
    return smin( d1, d2, k );
}

vec4 opBlend( vec4 d1, vec4 d2, float k ) {
  float tot = d1.x + d2.x;

  return vec4(
    smin( d1.x, d2.x, k ),
    1. / tot * (d1.yzw * (tot - d1.x) + d2.yzw * (tot - d2.x))
  );
}

// t = time to start transition
// tt = transition length
vec2 opMorph( vec2 d1, vec2 d2, float t, float tt ) {
  float k = (a - t) / tt;

  /*
  k = min(1., k);
  k = max(0., k);
  */

  k = clamp(0., k, 1.);

  return vec2(
    d1.x * (1. - k) + d2.x * k,
    d1.y * (1. - k) + d2.y * k
  );
}

vec4 opU(vec4 d1, vec4 d2) {
  return (d1.x<d2.x) ? d1 : d2;
}

vec3 opRep(vec3 p, vec3 c) {
  return mod(p,c)-.5*c;
}

vec3 opTwist(vec3 p) {
  float  c = cos(p.y);
  float  s = sin(p.y);
  mat2   m = mat2(c,-s,s,c);
  return vec3(m*p.xz,p.y);
}

// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

vec2 pRvec(inout vec2 p, float a) {
	return cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float fCapsule(vec3 p, float r, float c) {
	return mix(length(p.xz) - r, length(vec3(p.x, abs(p.y) - c, p.z)) - r, step(c, abs(p.y)));
}

float sdSphere(vec3 p, float s) {
  return length(p)-s;
}

float sdBloodCell(vec3 p) {
  float d1 = length(vec2(length(p.xz)-.3,p.y)) - .1;
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(.3,.06);
  float d2 = min(max(d.x,d.y),.0) + length(max(d,.0));

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
  float plasma1 = calcPlasma(p.x, p.y, p.z, a / 10.) + .5;

  return vec4(
    // tunnel shape
    (1. - c * .25) * (cos(p.x) + sin(p.y) + sin(p.z)) / 5.

    // blobby surface
    + (1. - c) * .05 * sin(10. * p.x) * sin(10. * p.y) * sin(10. * p.z) * sin(plasma1),

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

vec4 bloodCellWall(vec3 p) {
  p -= vec3(1.,0.,0.);

  vec3 col = vec3(1., .1, .1);

  pR(p.xy, 1.);
  vec3 rotated = p;
  pR(rotated.xy, a / 6.);
  pR(rotated.yz, a / 7.);
  vec4 res = vec4(sdBloodCell(rotated), col);

  // repeat
  p += vec3(1.,1.,0.);
  rotated = p;
  pR(rotated.xy, a / 6.);
  res = opU(res, vec4(sdBloodCell(rotated.yxz), col));

  // repeat
  p -= vec3(0.,4.,0.);
  rotated = p;
  pR(rotated.yz, a / 7.);
  res = opU(res, vec4(sdBloodCell(rotated.yzx), col));

  // repeat
  p += vec3(1.,1.,0.);
  rotated = p;
  pR(rotated.xy, a / 6.);
  res = opU(res, vec4(sdBloodCell(rotated), col));

  // repeat
  p += vec3(0.,2.,.2);
  rotated = p;
  pR(rotated.xz, a / 6.);
  res = opU(res, vec4(sdBloodCell(rotated.xzy), col));

  // repeat
  p -= vec3(2.,2.,0.);
  rotated = p;
  pR(rotated.yz, a / 7.);
  res = opU(res, vec4(sdBloodCell(rotated.yxz), col));

  // repeat
  p += vec3(3.,1.,0.);
  rotated = p;
  pR(rotated.xy, -a / 4.);
  res = opU(res, vec4(sdBloodCell(rotated), col));

  return res;
}

vec4 bloodCellField(vec3 p, float v) {
  // set up the correct rotation axis
  p.z += 3.;
  p.x += 15.; // move rotational origo to center of blood vein
  pR(p.xz, -(a * v + e) / 20.); // give speed to blood wall
  pModPolar(p.xz, 24.); // Rotate and duplicate blood wall around torus origo
  p -= vec3(15.,0.,0.);

  vec4 res = bloodCellWall(p);
  // duplicate wall
  // pR(p.xy, 1.);
  // res = opU(res, bloodCellWall(p));
  return res;
}

vec4 bloodVein(vec3 p,float v) {
  float plasma1 = calcPlasma(p.x / 8., p.y / 8., p.z / 8., a / 10.);

  // rotate
  // pR(p.xy, a/5.);
  return vec4(
    // tunnel shape
    sdTorus(p + vec3(14.,0.,1.5))

    // blobby surface
    - 0.05 * (1. + sin(3.0 * (p.z + a*v))),

    // color
    sin(vec3(1., .1, .1) * (plasma1 / 2. + .5))
  );
}

vec4 virus(vec3 pos, float size) {
  // velocity
  pR(pos.xy, PI/4.);

  float scale = 1. + c / 10.;
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

float udBox( vec3 p, vec3 b ) {
  return length(max(abs(p)-b,0.0));
}

float sdTorus2(vec3 p) {
  // the first constant sets size of torus
  // second sets size of middle
  return length(vec2(length(p.xz)-.5,p.y)) - 0.1;
}

vec4 sdArm(vec3 p, float len_arm, float angle) {
  vec4 res = vec4(fCapsule(p, .05,len_arm), .1,.1,.1);
  p.y += len_arm;
  pR(p.xy, angle);
  p.y += len_arm;
  res = opU(res, vec4(fCapsule(p, .05,len_arm), .1,.1,.1));
  return res;
}

vec4 vessel(vec3 pos, bool laser) {
  vec3 origPos = pos;

  pR(pos.xy, PI/2.);
  vec4 res = vec4(sdTriPrism(pos , vec2(.5,.3)), .9,.9,.9);
  pR(pos.xz, PI/2.);
  res = opI(res, vec4(sdTriPrism(pos , vec2(.7)), .9,.9,.9));
  pR(pos.zy, PI/2.);
  res = opI(res, vec4(sdHexPrism(pos, vec2(.3,.5)), .9,.9,.9));
  pos.z += .5;
  res = opU(res, vec4(sdHexPrism(pos, vec2(.3,.4)), .9,.9,.9));

  pR(pos.yz, PI/2.);
  res = opU(res, vec4(sdTriPrism(pos , vec2(.8,.01)), .9,.9,.9));
  pR(pos.xz, PI/2.);
  pos.x += .2;
  pos.y += .15;
  res = opU(res, vec4(sdTriPrism(pos , vec2(.5,.01)), .9,.9,.9));

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
    pos = origPos;
    pR(pos.xy, PI/2.);
    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.0, .95, -.35), 0.01, 1.),
        100., .1, .1
      )
    );

    res = opU(
      res,
      vec4(
        fCapsule(pos - vec3(.0, .95, .35), 0.01, 1.),
        100., .1, .1
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

float v = 2.;
// SCENES
vec4 scene0(vec3 pos) {
  vec4 res = vec4(sdSphere(pos,.01),1.,.0,.0);

  res = opU(res, bloodVein(pos,v));
  res = opU(res, bloodCellField(pos,v));
  pR(pos.yx,.5);
  res = opU(res, bloodCellField(pos,v*.8));
  return res;
}

vec4 scene1(vec3 pos) {
  vec4 res = vec4(sdSphere(pos,.01),1.,.0,.0);

  //vec3 pos_vessel = pos + vec3(.0,0.,1.);
  //pR(pos_vessel.xz, PI/2.);
  //res = opU(res, vessel(pos_vessel));
  // pR(pos.xz, -3.14/2.);
  res = opU(res, bloodVein(pos,v));
  res = opU(res, bloodCellField(pos,v));
  pos += vec3(.2);
  pR(pos.yx, .5);
  res = opU(res, bloodCellField(pos,v*.8));
  // );

  return res;
}

vec4 scene2(vec3 pos) {
  vec4 res = vec4(sdSphere(pos,.01),1.,.0,.0);

  res = opU(res, bloodVein(pos,v));
  res = opU(res, bloodCellField(pos,v));


  // res = opU(
  //   res,
  //   virus(
  //     vec3(pos.x+cos(a),pos.y+sin(a),pos.z+sin(a*.2)*3.),
  //     cos(a/2.)
  //   )
  // );

  return res;
}


vec4 scene3(vec3 pos) {
  // pos += vec3(0., 1., -4.);

  //pos += vec3(sin(a / 8.) / 4.,1.,1.);
  pR(pos.yz, 7.);
  pR(pos.xy, a/20.);
  pos += vec3(1., 1., 1.);
  return opBlend(
    heart(pos),
    virus(pos + vec3(.5), 1.),
    50.
  );
}

vec4 scene4(vec3 pos) {

  //pR(pos.xz, a / 2.);
  pR(pos.xy, -.4);
  pR(pos.xz, -.4);
  pos += vec3(sin(a) / 4.,1.,4.);
  //pR(pos.zy, a);
  // vessel
  vec4 res = opBlend(
    heart(pos),
    virus(pos + vec3(.5), 1.),
    50.
  );

  pR(pos.yz, sin(a / 4.) / 8.);
  pR(pos.xy, PI / 8.);
  return opBlend(
    res,
    vessel(pos - vec3(6. - a / 4., .0, .5), false),
    10.
  );
}

vec4 scene4_1(vec3 pos) {

  pR(pos.yz, .6);
  pR(pos.xz, -3.);
  pos += vec3(a / 16. - 1.,1.,-1.);
  //pR(pos.zy, a);
  // vessel
  vec4 res = opBlend(
    heart(pos),
    virus(pos + vec3(.5), 1.5 / (1. + a / 10.)),
    50.
  );

  pR(pos.xz, PI / 6.);
  pR(pos.xy, PI / 8.);
  return opU(
    res,
    vessel(pos - vec3(1., .0, -.2), true)
  );
}

vec4 scene5(vec3 pos) {
  pos.z += 1.;

  pR(pos.xz, a);
  return vessel(pos + vec3(.0,.5,.0), true);
}

vec4 map(in vec3 pos, in vec3 origin) {
  vec2 res = vec2(.0);

  float transitionTime = 10.;
  float end0 = 20.;
  float end1 = 34.;
  float end2 = 50.;
  float end3 = 70.;

  /* ---------- DEBUGGING ---------- */
  // Uncomment when debugging single scene
  return scene2(pos);

  /* ---------- SCENES --------- */

  /*
  // first scene
  if (a < end0 + transitionTime) {
    res = scene0(pos);
  }

  // start rendering after previous scene,
  // stop rendering after transitioning to next scene
  if (a >= end0 && a < end1 + transitionTime) {
    res = opMorph(res,
      scene1(pos + vec3(a, .0, sin(a))),

      // Timing
      end0,
      transitionTime
    );
  }

  // start rendering after previous scene,
  // stop rendering after transitioning to next scene
  if (a >= end1 && a < end2 + transitionTime) {
    res = opMorph(res,
      scene2(pos),

      // Timing
      end1,
      transitionTime
    );
  }

  if (a >= end2 && a < end3 + transitionTime) {
    res = opMorph(res,
      scene3(pos),

      // Timing
      end2,
      transitionTime
    );
  }

  // last scene
  if (a >= end3) {
    res = opMorph(res,
      scene3(pos),

      // Timing
      end3,
      transitionTime
    );
  }

  return res;
  */
}

vec4 castRay(in vec3 ro, in vec3 rd) {
  const int maxIterations = 64;
  float tmin = .02;
  float tmax = 50.;

  float t = tmin;
  vec3 m = vec3(-1.);
  for( int i=0; i<maxIterations; i++ ) {
    float precis = .000001*t;
    vec4 res = map( ro+rd*t, ro );
    if( res.x<precis || t>tmax ) break;
    t += res.x;
    m = res.yzw;
  }

  if( t>tmax ) m=vec3(-1.);
  return vec4( t, m );
}


float softshadow(in vec3 ro, in vec3 rd, in float mint, in float tmax) {
  float res = 2.;
  float t = mint;

  for( int i=0; i<4; i++ ) {
    float h = map( ro + rd*t, ro ).x;
    res = min( res, 8.*h/t );
    t += clamp( h, .02, .10 );
    if( h<.001 || t>tmax ) break;
  }

  return clamp( res, .0, 1. );
}

vec3 calcNormal(in vec3 pos) {
  vec2 e = vec2(1.,-1.)*.5773*.0005;
  return normalize( e.xyy*map( pos + e.xyy, pos ).x +
    e.yyx*map( pos + e.yyx, pos ).x +
    e.yxy*map( pos + e.yxy, pos ).x +
    e.xxx*map( pos + e.xxx, pos ).x );
}

float calcAO(in vec3 pos, in vec3 nor) {
  float occ = .0;
  float sca = 1.;

  for(int i=0; i<6; i++) {
    float hr = .01 + .12*float(i)/4.;
    vec3 aopos =  nor * hr + pos;
    float dd = map( aopos, pos ).x;
    occ += -(dd-hr)*sca;
    sca *= .95;
  }

  return clamp( 1. - 3.*occ, .0, 1. );
}

vec3 render(in vec3 ro, in vec3 rd) {
  vec3 col = vec3(.03, .04, .05);
  //vec3 col = vec3(.05, .05, .05) +rd.y*.1;
  vec4 res = castRay(ro,rd);
  float t = res.x;
  vec3 m = res.yzw;
  if( length(m)>.1 ) {
    vec3 pos = ro + t*rd;
    vec3 nor = calcNormal( pos );
    vec3 ref = reflect( rd, nor );

    // material
    //col = .45 + .35*sin( vec3(.05,.08,.10)*(m-1.0) );
    col = m;
    /*
    if( m<1.5 ) {
      float f = mod( floor(5.0*pos.z) + floor(5.0*pos.x), 2.0);
      col = .3 + .1*f*vec3(1.0);
    }
    */

    float occ = calcAO( pos, nor );
    vec3  lig = normalize( vec3(.4, .7, .6) );
    float amb = clamp( .5+.5*nor.y, .0, 1. );
    float dif = clamp( dot( nor, lig ), .0, 1. );
    //float bac = clamp( dot( nor, normalize(vec3(-lig.x,.0,-lig.z))), .0, 1. )*clamp( 1.-pos.y,.0,1.);
    float dom = smoothstep( -.1, .1, ref.y );
    float fre = pow( clamp(1.+dot(nor,rd),.0,1.), 2. );
    float spe = pow(clamp( dot( ref, lig ), .0, 1. ),2.);

    dif *= softshadow( pos, lig, .02, 2.5 );
    dom *= softshadow( pos, ref, .02, 2.5 );

    vec3 lin = vec3(.0);
    lin += dif;
    lin += spe*dif;
    lin += pow(.4*amb*occ, 2.);
    lin += pow(.2*dom*occ, 4.);
    //lin += .5*bac*occ;
    lin += .5*fre*occ;
    col = col*lin;

    // fog
    col = mix( col, vec3(.03, .04, .05), 1.-exp( -.001*t*t*t ) );

    /*
    float fade = 1. - min(1., (a - 2.)  / 8.);
    col = mix( col, vec3(.0), fade );
    */
  }

  return vec3( clamp(col,.0,1.) );
}

mat3 setCamera(in vec3 ro, in vec3 ta, float cr) {
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );

  return mat3( cu, cv, cw );
}

void main() {

  vec3 tot = vec3(.0);
  for( int m=0; m<2; m++ )   // 2x AA
  for( int n=0; n<2; n++ ) { // 2x AA
    // pixel coordinates
    vec2 o = vec2(float(m),float(n)) / float(2) - .5;
    vec2 p = (-b.xy + 2.*(gl_FragCoord.xy+o))/b.y;

    // camera
    // ro = ray origin = where the camera is
    // ta = camera direction (point which the camera is looking at)
    // cr = camera rotation
    float x = cos(a/2.);
    float y = sin(a/2.);
    float z = sin(a/2.)/2.+.5;

    // rotating camera
    vec3 pos = vec3(x,y,z);
    // vec3 ro = pos.xzy*2.;
    // static camera
    vec3 ro = vec3(.0,.0,1.);
    vec3 ta = vec3( .0 );
    // camera-to-world transformation
    mat3 ca = setCamera( ro, ta, .0 );
    // ray direction
    vec3 rd = ca * normalize( vec3(p.xy,2.) );

    // render
    vec3 col = render( ro, rd );

  	// gamma
    col = pow( col, vec3(.6, .5, .4) );

    tot += col;
  }

  tot /= 4.; // AA * AA

  gl_FragColor = vec4( tot, 1. );
}
