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

vec4 wave(vec3 pos) {
  // wave normal
  vec3 n = normalize(vec3(0.,1.,1.));
  // tilt the wave normal here
  // n.y += .5 ;//* sin(a.z);
  float r = 1.;
  // texture
  vec3 c = cos(pos);
  float tan_component = tan(pos.x);
  // float cos_component = cos(pos.x);
  float sin_component = .5 + sin(pos.x);
  c = vec3(0., .2, .9);
  // n.z += sin(a.z);
  return vec4(dot(pos, n)
  // + sin(pos.x + t) * .5
  // + pow((0.5 + 0.5 * sin(pos.x * 2. * .3 - a.z * .5)), 5.0)
  ,
  (mod(pos.y, 1.) == sin_component ? vec3(1.) : c)
  );
}

float origin_vector(vec3 p) {
  p.x += .2;
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(.01,.2);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
vec4 origin_drawer(vec3 p) {
  // don't modify the current p
  vec3 tmp_pos = p;
  // move to origo
  tmp_pos.y -= .2;
  tmp_pos.x -= .2;
  pR(tmp_pos.xy, PI / 2.);

  vec4 res,x,y,z;
  // x-axis
  x = vec4(origin_vector(tmp_pos.xyz), vec3(0.,0.,1.));
  // rotate to y-oxis
  pR(tmp_pos.xy, -PI/2.);
  y = vec4(origin_vector(tmp_pos.xyz), vec3(1.,0.,0.));
  // rotate to z-axis
  pR(tmp_pos.zy, PI/2.);
  // move axis to origo
  tmp_pos.y += .2;
  tmp_pos.z += .2;
  z = vec4(origin_vector(tmp_pos.xyz), vec3(0.,1.,0.));
  res = x;
  res = opBlend(y,res,0.);
  res = opBlend(z,res,0.);
  return res;
}

vec4 map(vec3 pos) {
  float t = a.z,
        colorMod = 1.,
        laser = 0.,
        rotateVessel = 1.,
        scene = 0.,
        virusSize = 0.;

  vec2 onezero = vec2(1.,0.);
  vec3 wpos = pos, spos = pos;
  // wpos.z += 10.;
  spos.x -= t / 20.;

  // vec4 sphere = vec4(length(spos) - .05, 1.,0.,0.);

  // wave
  vec4 res = origin_drawer(pos);
  // vec4 res = wave(wpos + 5.);

  res = opBlend(wave(wpos + 5.), res, 0.);
  // res = opBlend(sphere, res, 0.);
  return res;

  // // SCENE 1: Inside heart
  // if ((t -= 19.2) < 0.) {
  //   pR(heartPos.xz, t / 6.); pR(heartPos.xy, t / 5.);
  //   heartPos += 1.;
  //   vesselPos += 9.;
  // }
  //
  // // SCENE 2: Nanobot in blood vein
  // else
  //
  // if ((t -= 19.2) < 0.) {
  //   // select blood vessel scene
  //   scene = 1.;
  // }
  // // SCENE 2
  // else
  //
  // {
  //   heartPos += 2. - t / 10.;
  //   vesselPos = heartPos;
  //
  //   // rotate
  //   pR(vesselPos.xz, PI / 2.);
  //
  //   vesselPos += vec3(t - 5., -1, 1);
  // }
  // return opBlend(
  //   // heart & virus
  //   scene == 0. ? heart(heartPos, virusSize, colorMod) : bloodVein(bloodVeinPos, colorMod),
  //   vessel(vesselPos, laser),
  //   .1 + laser / 4.
  // );
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

  for(float i = 0.; i < 50.; i++) // 50. = maxIterations
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
    mix(col, vec3(.01), 1. - exp(-.001 * t * t * t)),

  	// gamma
    vec3(.6, .5, .4)
  )

  // // fade in
  // * pow(min((a.z - 1.) / 8., 1.), 2.)
  // // fade out
  // * pow(clamp((135. - a.z) / 8., 0., 1.), 2.) // 135. = demo length in seconds
  ;
  // vignette
  // * pow(1. - .001 * length((2. * gl_FragCoord.xy - a.xy)), 2.);

  gl_FragColor = vec4(tot, 1); // 4 = AA * AA
}
