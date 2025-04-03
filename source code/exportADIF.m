%% 自定义ADIF导出函数
function exportADIF(data, filename)
    % 创建ADIF文件头
    header = {
        'ADIF Export'
        '<ADIF_VER:5>3.1.4'
        '<CREATED_TIMESTAMP:15>%s'
        '<PROGRAMID:6>Logger'
        '<EOH>'
    };
    
    fid = fopen(filename, 'w', 'n', 'UTF-8');
    
    % 写入文件头
    fprintf(fid, '%s\n', header{1:4});
    fprintf(fid, '%s\n', sprintf(header{4}, datestr(now, 'yyyymmdd HHMMSS')));
    fprintf(fid, '%s\n\n', header{5});
    
    % 遍历每条记录
    for i = 1:length(data)
        % 转换字段到ADIF格式
        fields = {
            ['<CALL:' num2str(length(data(i).Callsign)) '>' data(i).Callsign]
            ['<FREQ:' num2str(length(data(i).Frequency_KHz)) '>' num2str(data(i).Frequency_KHz/1000)] % 转为MHz
            ['<MODE:' num2str(length(data(i).Mode)) '>' upper(data(i).Mode)]
            ['<QSO_DATE:8>' datestr(datenum(data(i).Time), 'yyyymmdd')]
            ['<TIME_ON:6>' datestr(datenum(data(i).Time), 'HHMMSS')]
            ['<RST_SENT:' num2str(length(data(i).RST_Sent)) '>' data(i).RST_Sent]
            ['<RST_RCVD:' num2str(length(data(i).RST_Received)) '>' data(i).RST_Received]
        };
        
        % 写入字段
        fprintf(fid, '%s\n', fields{:});
        fprintf(fid, '<EOR>\n\n'); % 记录结束符
    end
    
    fclose(fid);
end
