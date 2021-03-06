const fs = require('fs');
const os = require('os');
const argv = require('yargs').argv;

/*
 * 3 args required:
 * --template: which file do we replace in?
 * --find: what string do we search for in the template?
 * --replace: what file do we replace the match with?
*/

//console.log(argv.find);
//console.log(argv.surround);

let resuls = '';
var isWin = (os.platform() === 'win32');

if (isWin) {
	let template = fs.readFileSync(argv.template).toString();

	var replace = '';
	if (!argv.replace) {
		var stdin = process.openStdin();
		stdin.resume();
		stdin.setEncoding('utf8');
		stdin.on('data', function(chunk) {
			replace += chunk;
			console.log(replace);
		});
		console.log("Replacing string is now:");
		console.log(replace);
		console.log("look above");
		//var size = fs.fstatSync(process.stdin.fd).size;
		//replace = size > 0 ? fs.readSync(process.stdin.fd, size)[0] : '';
	} else {
		replace = argv.replace;
		replace = fs.readFileSync(argv.replace, 'utf8');
	}

	var re = new RegExp(argv.find, "g");
	if (argv.surround) replace = argv.surround + replace + argv.surround;
	result = template.replace(argv.find, replace);
	
	//console.log(result);
} else {

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
	result = template;

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
}

