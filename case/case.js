const url = new URL(window.location.href);
let p = new URLSearchParams(url.search);
let caseId = p.get('id');
const path = '../' + config.path;

$(window).ready(() => {
    $.get(`${path}/summary.json`, (data) => {
        let x = data.cases.find((x) => x.id == caseId);
        //console.log(x);

        $('#caseId div.part3').html(x.id);
        $('#caseId div.part1').addClass('retCode_' + x.l2v5RetCode);
        $('#caseId div.part2').addClass('retCode_' + x.l3v2RetCode);
        $('#casePath').html(`${path}/cases/${x.id}/`);
        $('#retCode').html(x.l2v5RetCode);

        $.get(`${path}/cases/${x.id}/synopsis.txt`, (data) => {
            //let shorted = splitLines(data);
            $('#synopsis pre code').html(data);
        }).fail(() => {
            $('#synopsis pre code').html('No synopsis.txt file found');
        });

        $.get(`${path}/cases/${x.id}/l2v5/heta-code/output.heta`, (data) => {
            $('#heta-code-l2v5 pre code').html(data);
        }).fail(() => {
            $('#heta-code-l2v5 pre code').html('No l2v5/heta-code/output.heta file found');
        });
        $.get(`${path}/cases/${x.id}/l2v5/build.log`, (data) => {
            $('#logs-l2v5 pre code').html(data);
        }).fail(() => {
            $('#logs-l2v5 pre code').html('No l2v5/build.log file found');
        });
        
        $.get(`${path}/cases/${x.id}/l3v2/heta-code/output.heta`, (data) => {
            $('#heta-code-l3v2 pre code').html(data);
        }).fail(() => {
            $('#heta-code-l3v2 pre code').html('No l3v2/heta-code/output.heta file found');
        });
        $.get(`${path}/cases/${x.id}/l3v2/build.log`, (data) => {
            $('#logs-l3v2 pre code').html(data);
        }).fail(() => {
            $('#logs-l3v2 pre code').html('No l3v2/build.log file found');
        });
    });
});

function splitLines(s) {
    let newS = [];
    s.split('\n').forEach((line) => {
        if (line.length <= 180) {
            newS.push(line);
        } else {
            let i = 0;
            while (i < line.length) {
                newS.push(line.slice(i, i + 100));
                i += 100;
            }
        }
    });

    return newS.join('\n');
}
