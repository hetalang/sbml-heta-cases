const BASE_DIR = process.env.BASE_DIR || './';
const path = require('path');
const fse = require('fs-extra');
const summaryPath = path.resolve(BASE_DIR, '../sbml/summary');
const summary = require(summaryPath);


let html = ''
html += '<html><head><style></style></head><body><ul>'
summary.cases.forEach((item) => {
    if (!item.l3v2RetCode) {
        var hetaPath = path.resolve(BASE_DIR, '../sbml', item.id, 'l3v2/heta-code/output.heta');
    } else if (!item.l2v5RetCode) {
        hetaPath = path.resolve(BASE_DIR, '../sbml', item.id, 'l2v5/heta-code/output.heta');
    } else {
        return; // skip if no heta files
    }

    // copy heta files
    let heta = fse.readFileSync(hetaPath, 'utf8');

    // input description as comment
    let synop = fse.readFileSync(path.resolve(BASE_DIR, '../sbml', item.id, 'synopsis.txt'), 'utf8');
    
    // write heta file
    let fullContent = `/*${synop}*/\n\n${heta}`;
    fse.writeFileSync(path.resolve(BASE_DIR, item.id, 'output.heta'), fullContent);

    // update html page
    html += `<li><a href="${item.id}/output.heta">${item.id}</a></li>`;
});

html += '</ul></body></html>';

fse.writeFileSync(path.resolve(BASE_DIR, 'index.html'), html);