$(window).ready(() => {
    $('#modal .close').click(() => {
        $('#modal').hide();
    });
    $.get(`${config.path}/summary.json`, (data) => {
        // general statistics
        $('#heta_version').html(data.hetaCompilerVersion);
        $('#started').html(data.started);
        $('#finished').html(data.finished);
        $('#totalCasesCount').html(data.totalCasesCount);

        // display statistics L2V5
        let l2v5_code_0_stat = data.cases.filter((x) => x.l2v5RetCode == 0).length;
        let l2v5_code_1_stat = data.cases.filter((x) => x.l2v5RetCode == 1).length;
        let l2v5_code_2_stat = data.cases.filter((x) => x.l2v5RetCode == 2).length;
        let l2v5_code_9_stat = data.cases.filter((x) => x.l2v5RetCode == 9).length;

        $('#l2v5_code_0_stat').html(l2v5_code_0_stat);
        $('#l2v5_code_1_stat').html(l2v5_code_1_stat);
        $('#l2v5_code_2_stat').html(l2v5_code_2_stat);
        $('#l2v5_code_9_stat').html(l2v5_code_9_stat);

        // display statistics L3V2
        let l3v2_code_0_stat = data.cases.filter((x) => x.l3v2RetCode == 0).length;
        let l3v2_code_1_stat = data.cases.filter((x) => x.l3v2RetCode == 1).length;
        let l3v2_code_2_stat = data.cases.filter((x) => x.l3v2RetCode == 2).length;
        let l3v2_code_9_stat = data.cases.filter((x) => x.l3v2RetCode == 9).length;

        $('#l3v2_code_0_stat').html(l3v2_code_0_stat);
        $('#l3v2_code_1_stat').html(l3v2_code_1_stat);
        $('#l3v2_code_2_stat').html(l3v2_code_2_stat);
        $('#l3v2_code_9_stat').html(l3v2_code_9_stat);

        data.cases.forEach((x) => {
            let item =$(`<div class="item retCode_${x.l2v5RetCode}">${x.id}</div>`)
                .appendTo('#summary');
            item.on('click', () => {
                $('#caseId').html(x.id);
                $('#caseId').removeClass().addClass('retCode_' + x.l2v5RetCode);
                $('#casePath').html(`${config.path}/${x.id}/`);
                $('#retCode').html(x.l2v5RetCode);
                $('#modal').show();

                $.get(`${config.path}/${x.id}/synopsis.txt`, (data) => {
                    let shorted = splitLines(data);
                    $('#modal #synopsis pre code').html(shorted);
                }).fail(() => {
                    $('#modal #synopsis pre code').html('No synopsis.txt file found');
                });

                $.get(`${config.path}/${x.id}/l2v5/heta-code/output.heta`, (data) => {
                    $('#modal #heta-code-l2v5 pre code').html(data);
                }).fail(() => {
                    $('#modal #heta-code-l2v5 pre code').html('No l2v5/heta-code/output.heta file found');
                });
                $.get(`${config.path}/${x.id}/l2v5/build.log`, (data) => {
                    $('#modal #logs-l2v5 pre code').html(data);
                }).fail(() => {
                    $('#modal #logs-l2v5 pre code').html('No l2v5/build.log file found');
                });
                
                $.get(`${config.path}/${x.id}/l3v2/heta-code/output.heta`, (data) => {
                    $('#modal #heta-code-l3v2 pre code').html(data);
                }).fail(() => {
                    $('#modal #heta-code-l3v2 pre code').html('No l3v2/heta-code/output.heta file found');
                });
                $.get(`${config.path}/${x.id}/l3v2/build.log`, (data) => {
                    $('#modal #logs-l3v2 pre code').html(data);
                }).fail(() => {
                    $('#modal #logs-l3v2 pre code').html('No l3v2/build.log file found');
                });
            });
        });
        
    }, 'json');
    /*
    $.get(config.results || 'results.json', (data) => {
        // version and runtime info
        $('#heta_version')
            .html('<strong>Heta compiler version:</strong> ' + data.heta_version);
        $('#solver')
            .html('<strong>Solver:</strong> ' + data.solver);
        $('#solver_version')
            .html('<strong>Solver version:</strong> ' + data.solver_version);
        $('#date')
            .html('<strong>Date:</strong> ' + data.date);
        $('#required_time')
            .html('<strong>Runtime:</strong> ' + Math.round(data.required_time/60) + ' min');

        let casesArray = Object.values(data.cases);

        // statistics
        let success_count = casesArray.filter((x) => x.result?.status === 'SUCCESS').length;
        $('#SUCCESS_status')
            .html(`<strong>SUCCESS:</strong> ${success_count} (${(success_count/casesArray.length*100).toPrecision(2)}%)`);

        let tolerance_fail_count = casesArray.filter((x) => x.result?.status === 'TOLERANCE_FAIL').length;
        $('#TOLERANCE_FAIL_status')
            .html(`<strong>TOLERANCE_FAIL:</strong> ${tolerance_fail_count} (${(tolerance_fail_count/casesArray.length*100).toPrecision(2)}%)`);

        let error_count = casesArray.filter((x) => x.result?.status === 'ERROR').length;
        $('#ERROR_status')
            .html(`<strong>ERROR:</strong> ${error_count} (${(error_count/casesArray.length*100).toPrecision(2)}%)`);
            
        let skipped_count = casesArray.filter((x) => x.result?.status === 'SKIPPED').length;
        $('#SKIPPED_status')
            .html(`<strong>SKIPPED:</strong> ${skipped_count} (${(skipped_count/casesArray.length*100).toPrecision(2)}%)`);

        let undefined_count = casesArray.filter((x) => x.result?.status === undefined).length;
        $('#undefined_status')
            .html(`<strong>undefined:</strong> ${undefined_count} (${(undefined_count/casesArray.length*100).toPrecision(2)}%)`);

        // color panel
        let container = $('#container');
        casesArray.forEach((x) => {

            let componentTags = x.tags?.componentTags?.join(', ');
            let testTags = x.tags?.testTags?.join(', ');
            let status = x.result?.status;
            let message = x.result?.message;
            let build_errors = x.build_errors?.map((line) => {
                return `<li>${line.msg}</li>`;
            }).join('');
            let description = `
                <h2>#${x.name}</h2>
                <p><strong>build_errors:</strong> <ul>${build_errors}</ul></p>
                <p><strong>status:</strong> ${status}</p>
                <p><strong>message:</strong> ${message}</p>
                <p><strong>componentTags:</strong> ${componentTags}</p>
                <p><strong>testTags:</strong> ${testTags}</p>
            `;

            let symb = {
                ERROR: ''
            }[status];
            $(`<div id="${x.name}" class="item ${status}">${symb ? symb : ''}<div class="hoovable">${description}</div></div>`)
                .appendTo(container);
            
        });
    }, 'json');
    // display graph
    $('#container').click((evt) => {
        let caseName = evt.target.id;
        let filename = caseName + '.png';
        let filepath = [config.figPath, filename].join('/');
        $('#figure img').prop('src', filepath);
    });
    */
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
