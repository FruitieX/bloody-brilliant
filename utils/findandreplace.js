const fs = require('fs');
const argv = require('yargs').argv;

/*
 * 3 args required:
 * --template: which file do we replace in?
 * --find: what string do we search for in the template?
 * --replace: what file do we replace the match with?
*/

let template = fs.readFileSync(argv.template);

//const replace = fs.readFileSync(argv.replace).toString();
let replace = fs.readFileSync('/dev/stdin');
let replaceS = replace.toString();

if (replaceS[replaceS.length -1] === '\n') {
  replace = replace.slice(0, -1);
}
/*
if (argv.surround) {
  replace = argv.surround + replace + argv.surround;
}
*/

const index = template.indexOf(argv.find);
let result = template;

// match found
if (index !== -1) {
  if (argv.surround) {
    result = new Buffer.concat([
      template.slice(0, index),
      new Buffer(argv.surround),
      replace,
      new Buffer(argv.surround),
      template.slice(index + argv.find.length)
    ]);
  } else {
    result = new Buffer.concat([
      template.slice(0, index),
      replace,
      template.slice(index + argv.find.length)
    ]);
  }
}

console.log(result.toString('utf8').trim());
