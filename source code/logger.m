classdef logger < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        LoggerUIFigure    matlab.ui.Figure
        TabGroup          matlab.ui.container.TabGroup
        Tab               matlab.ui.container.Tab
        Label_6           matlab.ui.control.Label
        ClearButton       matlab.ui.control.Button
        SaveButton        matlab.ui.control.Button
        RSTLabel_3        matlab.ui.control.Label
        ModeDropDown      matlab.ui.control.DropDown
        Label_2           matlab.ui.control.Label
        CancelButton      matlab.ui.control.Button
        Label_4           matlab.ui.control.Label
        ConfirmButton     matlab.ui.control.Button
        TimeTextArea      matlab.ui.control.TextArea
        Label_5           matlab.ui.control.Label
        NumTextArea_2     matlab.ui.control.TextArea
        RSTTextArea_2     matlab.ui.control.TextArea
        RSTLabel          matlab.ui.control.Label
        NumTextArea       matlab.ui.control.TextArea
        RSTLabel_2        matlab.ui.control.Label
        RSTTextArea       matlab.ui.control.TextArea
        Label_3           matlab.ui.control.Label
        CallsignTextArea  matlab.ui.control.TextArea
        KHzTextArea       matlab.ui.control.TextArea
        Label             matlab.ui.control.Label
    end



    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: ModeDropDown
        function ModeDropDownValueChanged(app, event)

            if app.ModeDropDown.Value == "CW"%CW模式下，信号报告RST默认记录为599
                app.RSTTextArea.Value="599";
                app.RSTTextArea_2.Value="599";
            elseif app.ModeDropDown.Value ~= "CW"%其他模式下，信号报告RST默认记录为59
                app.RSTTextArea.Value="59";
                app.RSTTextArea_2.Value="59";
            end
        end

        % Value changed function: KHzTextArea
        function KHzTextAreaValueChanged(app, event)
            
        end

        % Value changing function: KHzTextArea
        function KHzTextAreaValueChanging(app, event)
% 检查模式，如果模式是CW或者FT8则模式不随着频率发生改变
            if app.ModeDropDown.Value == "CW"
                return;
            elseif app.ModeDropDown.Value == "FT8"
                return;
            end
% 如果模式不是CW或者FT8，输入频率会改变模式
            changingValue = str2double(event.Value); 
            if changingValue<=10000
               app.ModeDropDown.Value="LSB";% 输入频率小于10000Khz时模式变为LSB
            elseif changingValue<=30000
                app.ModeDropDown.Value="USB";%输入频率在10000KHz到30000Khz时模式变为USB
            elseif changingValue>=140000 && changingValue>=148000
                app.ModeDropDown.Value="FM";%输入频率在140000KHz到148000Khz时模式变为FM
            elseif changingValue>=430000 && changingValue>=440000
                app.ModeDropDown.Value="FM";%输入频率在430000KHz到440000Khz时模式变为FM
            end
            app.ModeDropDown.Value
        end

        % Value changing function: RSTTextArea
        function RSTTextAreaValueChanging(app, event)
      
        end

        % Value changing function: RSTTextArea_2
        function RSTTextArea_2ValueChanging(app, event)
   
            
        end

        % Button pushed function: ConfirmButton
        function ConfirmButtonPushed(app, event)
            % 获取界面数据
            freq = app.KHzTextArea.Value;  % 频率
            mode = app.ModeDropDown.Value;  % 模式
            callsign = app.CallsignTextArea.Value;  % 呼号
            rst_sent = app.RSTTextArea_2.Value;  % 己方信号报告
            rst_recv = app.RSTTextArea.Value;  % 对方信号报告
            rst_num_sent = app.NumTextArea_2.Value;  % 己方序号
            rst_num_recv = app.NumTextArea.Value;  % 对方序号
            timestamp=app.TimeTextArea.Value;%获取自定义时间

            if timestamp == "yyyy-mm-dd HH:MM:SS"
                timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');% 当前时间
            end

            % 组织日志字符串

            logEntry = sprintf('%s | 频率: %s KHz | 模式: %s | 呼号: %s | RST(发): %s | RST(收): %s | 序号(发): %s | 序号(收): %s\n', ...
                string(timestamp), string(freq), string(mode), string(callsign), string(rst_sent), string(rst_recv), string(rst_num_sent), string(rst_num_recv));


            % 指定日志文件路径（可自定义路径）
            logFile = 'qso_log.log';

            % 追加写入到日志文件
            fid = fopen(logFile, 'a');  % 'a' 代表追加模式
            if fid == -1
                uialert(app.LoggerUIFigure, '无法打开日志文件！', '错误', 'Icon', 'error');
                return;
            elseif isempty(freq) || strlength(freq) == 0
                app.Label_6.Text = '频率不能为空';
                app.Label_6.FontColor = [1 0 0];
                return;
            elseif isempty(callsign) || strlength(callsign) == 0
                app.Label_6.Text = '呼号不能为空';
                app.Label_6.FontColor = [1 0 0];
                return; 
            end
            fprintf(fid, '%s', logEntry);
            fclose(fid);

           %确认通联信息后重置界面内容
            app.TimeTextArea.Value="yyyy-mm-dd HH:MM:SS";
            app.CallsignTextArea.Value="";
            app.NumTextArea.Value="";
            app.NumTextArea_2.Value=string(str2double(app.NumTextArea_2.Value)+1);
            if app.ModeDropDown.Value == "CW"%CW模式下，信号报告RST默认记录为599
                app.RSTTextArea.Value="599";
                app.RSTTextArea_2.Value="599";
            elseif app.ModeDropDown.Value ~= "CW"%其他模式下，信号报告RST默认记录为59
                app.RSTTextArea.Value="59";
                app.RSTTextArea_2.Value="59";
            end


            %
       try
            % 创建Java机器人实例
            robot = java.awt.Robot();
            
            % 设置按键间隔时间（单位：毫秒）
            keyInterval = 10; 
            
            % 模拟7次Tab键
            for i = 1:7
                robot.keyPress(java.awt.event.KeyEvent.VK_TAB);
                robot.keyRelease(java.awt.event.KeyEvent.VK_TAB);
                robot.delay(keyInterval); % 添加延迟确保执行顺序
            end
            
        catch ME
            uialert(app.LoggerUIFigure, ['焦点控制失败: ' ME.message], '系统错误');
        end

        end

        % Value changing function: TimeTextArea
        function TimeTextAreaValueChanging(app, event)

        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)
%清空当前所有输入内容          
            app.TimeTextArea.Value="yyyy-mm-dd HH:MM:SS";
            app.CallsignTextArea.Value="";
            app.NumTextArea.Value="";
            if app.ModeDropDown.Value == "CW"%CW模式下，信号报告RST默认记录为599
                app.RSTTextArea.Value="599";
                app.RSTTextArea_2.Value="599";
            elseif app.ModeDropDown.Value ~= "CW"%其他模式下，信号报告RST默认记录为59
                app.RSTTextArea.Value="59";
                app.RSTTextArea_2.Value="59";
            end
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
         % 读取日志文件
        logFile = 'qso_log.log';
        
        try
            % 打开日志文件
            fid = fopen(logFile, 'r');
            if fid == -1
                uialert(app.LoggerUIFigure, '日志文件不存在或无法打开！', '错误', 'Icon','error');
                return;
            end
        
           % 初始化数据存储结构
            data = struct(...
                'Time', {},...
                'Frequency_KHz', {},...
                'Mode', {},...
                'Callsign', {},...
                'RST_Sent', {},...
                'RST_Received', {},...
                'Serial_Sent', {},...
                'Serial_Received', {});
        
            % 逐行读取文件
            lineCount = 0;
            while ~feof(fid)
                line = fgetl(fid);
                lineCount = lineCount + 1;
                
                % 分割字段
                segments = split(line, '|');
                if numel(segments) ~= 8
                    uialert(app.LoggerUIFigure, sprintf('第%d行格式错误', lineCount), '解析错误', 'Icon','warning');
                    continue;
                end
                
                % 解析各个字段
                try
                    % 提取时间（去除前后空格）
                    timeStr = strtrim(segments{1});
                    
                    % 提取频率（去掉"频率: "和" KHz"）
                    freqStr = regexprep(strtrim(segments{2}), {'频率:\s*','\s*KHz'}, '');
                    
                    % 提取模式
                    modeStr = regexprep(strtrim(segments{3}), '模式:\s*', '');
                    
                    % 提取呼号
                    callsignStr = regexprep(strtrim(segments{4}), '呼号:\s*', '');
                    
                    % 提取RST报告
                    rstSent = regexprep(strtrim(segments{5}), 'RST\(发\):\s*', '');
                    rstRecv = regexprep(strtrim(segments{6}), 'RST\(收\):\s*', '');
                    
                    % 提取序号
                    serialSent = regexprep(strtrim(segments{7}), '序号\(发\):\s*', '');
                    serialRecv = regexprep(strtrim(segments{8}), '序号\(收\):\s*', '');
                    
                    % 存入结构体
                    data(end+1) = struct(...
                        'Time', {timeStr},...
                        'Frequency_KHz', {str2double(freqStr)},...
                        'Mode', {modeStr},...
                        'Callsign', {callsignStr},...
                        'RST_Sent', {rstSent},...
                        'RST_Received', {rstRecv},...
                        'Serial_Sent', {serialSent},...
                        'Serial_Received', {serialRecv});
                catch
                    uialert(app.LoggerUIFigure, sprintf('第%d行解析失败', lineCount), '解析错误', 'Icon','warning');
                end
            end
            fclose(fid);
        
            % 检查是否有数据
            if isempty(data)
                uialert(app.LoggerUIFigure, '没有可导出的通联记录', '提示', 'Icon','info');
                return;
            end
           

            % 转换为表格并设置中文列名
             dataTable = struct2table(data);
             dataTable.Properties.VariableNames = {
            '时间', 
            '频率_KHz', 
            '模式', 
            '呼号', 
            '己方信号报告RST', 
            '对方信号报告RST', 
            '己方通联序号', 
            '对方通联序号'
        };

            
            % 让用户选择保存位置和格式
            [filename, pathname] = uiputfile(...
                {'*.xlsx','Excel 工作簿 (*.xlsx)';...
                 '*.xls','Excel 97-2003 工作簿 (*.xls)';...
                 '*.csv','CSV 文件 (*.csv)';...
                 '*.adi','ADIF 日志文件 (*.adi)'},...
                '导出日志文件',...
                'qso_log.xlsx');
            
            if isequal(filename,0) || isequal(pathname,0)
                return; % 用户取消
            end
            
            % 获取文件扩展名
            [~,~,ext] = fileparts(filename);
            fullpath = fullfile(pathname, filename);
            
            % 根据文件类型执行不同导出操作
            switch lower(ext)
                case {'.xlsx', '.xls'}
                    % 导出Excel文件
                    writetable(dataTable, fullpath, 'FileType', 'spreadsheet');
                    msg = 'Excel文件导出完成';
                    
                case '.csv'
                    % 导出CSV文件（保留中文表头）
                    writetable(dataTable, fullpath, 'Encoding', 'UTF-8');
                    msg = 'CSV文件导出完成';
                    
                case '.adi'
                    % 导出ADIF格式文件
                    exportADIF(data, fullpath); % 调用ADIF导出函数
                    msg = 'ADIF文件导出完成';
                    
                otherwise
                    error('不支持的导出格式');
            end
            
            uialert(app.LoggerUIFigure, [msg '：' fullpath], '导出完成', 'Icon','success');
            
        catch ex
            uialert(app.LoggerUIFigure, ['导出失败：' ex.message], '错误', 'Icon','error');
            if exist('fid', 'var') && fid ~= -1
                fclose(fid);
            end
        end

        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
        fileToDelete = 'qso_log.log';
        
        % 创建确认对话框
        selection = uiconfirm(app.LoggerUIFigure,...
            '此操作会清空您所有的日志缓存，请确保日志文件导出保存后再操作！',...
            '警告',...
            'Options',{'确认','取消'},...
            'DefaultOption',2,...
            'CancelOption',2);
        
        % 根据用户选择执行操作
        if strcmp(selection, '确认')
            try
                if exist(fileToDelete, 'file')
                    delete(fileToDelete);
                    uialert(app.LoggerUIFigure, '日志文件已成功删除', '操作成功',...
                        'Icon','success'); % 添加成功图标
                    
                    %重置界面内容
                    app.TimeTextArea.Value="yyyy-mm-dd HH:MM:SS";
                    app.CallsignTextArea.Value="";
                    app.NumTextArea.Value="";
                    app.KHzTextArea.Value="";
                    app.NumTextArea_2.Value="";
                    if app.ModeDropDown.Value == "CW"%CW模式下，信号报告RST默认记录为599
                        app.RSTTextArea.Value="599";
                        app.RSTTextArea_2.Value="599";
                    elseif app.ModeDropDown.Value ~= "CW"%其他模式下，信号报告RST默认记录为59
                        app.RSTTextArea.Value="59";
                        app.RSTTextArea_2.Value="59";
                    end
           
                else
                    uialert(app.LoggerUIFigure, '日志文件不存在', '提示',...
                        'Icon','info'); % 添加信息图标
                end
            catch ME
                uialert(app.LoggerUIFigure,...
                    ['操作失败: ' ME.message],...
                    '错误',...
                    'Icon','error'); % 错误提示带红色图标
            end
        else
            % 用户点击取消时不执行任何操作
            return
        end
        end

        % Value changed function: CallsignTextArea
        function CallsignTextAreaValueChanged(app, event)
           
        end

        % Value changing function: CallsignTextArea
        function CallsignTextAreaValueChanging(app, event)
%过滤呼号非法字符
            
            rawInput = event.Value;
                    
                    try
                        % 转换大写并过滤非法字符
                        processed = upper(rawInput); % 转为大写
                        filtered = regexprep(processed, '[^A-Z0-9/]', ''); % 只保留字母数字和斜杠
                        
                        % 更新显示（保留光标位置）
                        if ~strcmp(app.CallsignTextArea.Value, filtered)
                            % 计算新旧文本差异
                            oldText = app.CallsignTextArea.Value;
                            newText = filtered;
                            
                            % 设置新值
                            app.CallsignTextArea.Value = newText;
                            
                        end
                        
                    catch ME
                        % 错误处理
                        uialert(app.LoggerUIFigure, ['输入处理错误: ' ME.message], '系统错误');
                    end
                      
            
            %呼号统计功能
            logFile = 'qso_log.log';
        try
            app.Label_6.Visible = 'on';
            currentCallsign = upper(strtrim(string(event.Value))); % 强制转为字符串

            qsoCount = 0;
            if exist(logFile, 'file')
                % 使用更可靠的文件读取方式
                fid = fopen(logFile, 'r');
                fileContent = textscan(fid, '%s', 'Delimiter', '\n'); % 精确按行读取
                fclose(fid);
                lines = fileContent{1};
                
                % 过滤空行
                validLines = ~cellfun(@isempty, lines);
                lines = lines(validLines);
                
                % 单模式匹配所有行
                matches = regexp(lines, currentCallsign); 
                qsoCount = sum(~cellfun(@isempty, matches));
            else
                app.Label_6.Text = '没有日志记录';
                app.Label_6.FontColor = [1 0 0];
                return;
            end
            
            % 更新显示
            app.Label_6.Text = sprintf('%s %d QSO Before', currentCallsign, qsoCount);
            app.Label_6.FontColor = [0 0.5 0]; % 绿色
            app.Label_6.FontSize = 14;
            
        catch ME
            app.Label_6.Text = sprintf('错误: %s', ME.message);
            app.Label_6.FontColor = [1 0 0];
        end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create LoggerUIFigure and hide until all components are created
            app.LoggerUIFigure = uifigure('Visible', 'off');
            app.LoggerUIFigure.Position = [100 100 677 318];
            app.LoggerUIFigure.Name = 'Logger';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.LoggerUIFigure);
            app.TabGroup.Position = [1 0 677 319];

            % Create Tab
            app.Tab = uitab(app.TabGroup);
            app.Tab.Title = '通联记录';

            % Create Label
            app.Label = uilabel(app.Tab);
            app.Label.HorizontalAlignment = 'center';
            app.Label.FontSize = 15;
            app.Label.Position = [24 227 74 22];
            app.Label.Text = '频率(KHz)';

            % Create KHzTextArea
            app.KHzTextArea = uitextarea(app.Tab);
            app.KHzTextArea.ValueChangedFcn = createCallbackFcn(app, @KHzTextAreaValueChanged, true);
            app.KHzTextArea.ValueChangingFcn = createCallbackFcn(app, @KHzTextAreaValueChanging, true);
            app.KHzTextArea.HorizontalAlignment = 'center';
            app.KHzTextArea.FontSize = 15;
            app.KHzTextArea.Position = [103 223 90 28];

            % Create CallsignTextArea
            app.CallsignTextArea = uitextarea(app.Tab);
            app.CallsignTextArea.ValueChangedFcn = createCallbackFcn(app, @CallsignTextAreaValueChanged, true);
            app.CallsignTextArea.ValueChangingFcn = createCallbackFcn(app, @CallsignTextAreaValueChanging, true);
            app.CallsignTextArea.HorizontalAlignment = 'center';
            app.CallsignTextArea.FontSize = 15;
            app.CallsignTextArea.Position = [129 170 116 30];

            % Create Label_3
            app.Label_3 = uilabel(app.Tab);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.FontSize = 15;
            app.Label_3.Position = [256 176 135 22];
            app.Label_3.Text = '对方信号报告(RST)';

            % Create RSTTextArea
            app.RSTTextArea = uitextarea(app.Tab);
            app.RSTTextArea.ValueChangingFcn = createCallbackFcn(app, @RSTTextAreaValueChanging, true);
            app.RSTTextArea.FontSize = 15;
            app.RSTTextArea.Position = [406 170 44 30];
            app.RSTTextArea.Value = {'59'};

            % Create RSTLabel_2
            app.RSTLabel_2 = uilabel(app.Tab);
            app.RSTLabel_2.HorizontalAlignment = 'right';
            app.RSTLabel_2.FontSize = 15;
            app.RSTLabel_2.Position = [477 176 107 22];
            app.RSTLabel_2.Text = '对方序号(Num)';

            % Create NumTextArea
            app.NumTextArea = uitextarea(app.Tab);
            app.NumTextArea.FontSize = 15;
            app.NumTextArea.Position = [599 170 44 30];

            % Create RSTLabel
            app.RSTLabel = uilabel(app.Tab);
            app.RSTLabel.HorizontalAlignment = 'right';
            app.RSTLabel.FontSize = 15;
            app.RSTLabel.Position = [256 131 135 22];
            app.RSTLabel.Text = '己方信号报告(RST)';

            % Create RSTTextArea_2
            app.RSTTextArea_2 = uitextarea(app.Tab);
            app.RSTTextArea_2.ValueChangingFcn = createCallbackFcn(app, @RSTTextArea_2ValueChanging, true);
            app.RSTTextArea_2.FontSize = 15;
            app.RSTTextArea_2.Position = [406 125 44 30];
            app.RSTTextArea_2.Value = {'59'};

            % Create NumTextArea_2
            app.NumTextArea_2 = uitextarea(app.Tab);
            app.NumTextArea_2.FontSize = 15;
            app.NumTextArea_2.Position = [599 127 44 30];
            app.NumTextArea_2.Value = {'1'};

            % Create Label_5
            app.Label_5 = uilabel(app.Tab);
            app.Label_5.HorizontalAlignment = 'center';
            app.Label_5.FontSize = 15;
            app.Label_5.Position = [25 87 108 22];
            app.Label_5.Text = '通联时间(Time)';

            % Create TimeTextArea
            app.TimeTextArea = uitextarea(app.Tab);
            app.TimeTextArea.ValueChangingFcn = createCallbackFcn(app, @TimeTextAreaValueChanging, true);
            app.TimeTextArea.HorizontalAlignment = 'center';
            app.TimeTextArea.FontSize = 15;
            app.TimeTextArea.Position = [140 81 232 35];
            app.TimeTextArea.Value = {'yyyy-mm-dd HH:MM:SS'};

            % Create ConfirmButton
            app.ConfirmButton = uibutton(app.Tab, 'push');
            app.ConfirmButton.ButtonPushedFcn = createCallbackFcn(app, @ConfirmButtonPushed, true);
            app.ConfirmButton.Position = [319 25 108 38];
            app.ConfirmButton.Text = '确认(Confirm)';

            % Create Label_4
            app.Label_4 = uilabel(app.Tab);
            app.Label_4.HorizontalAlignment = 'center';
            app.Label_4.FontSize = 15;
            app.Label_4.Position = [24 176 99 22];
            app.Label_4.Text = '呼号(Callsign)';

            % Create CancelButton
            app.CancelButton = uibutton(app.Tab, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.Position = [440 25 108 38];
            app.CancelButton.Text = '取消(Cancel)';

            % Create Label_2
            app.Label_2 = uilabel(app.Tab);
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.FontSize = 15;
            app.Label_2.Position = [215 227 83 22];
            app.Label_2.Text = '模式(Mode)';

            % Create ModeDropDown
            app.ModeDropDown = uidropdown(app.Tab);
            app.ModeDropDown.Items = {'USB', 'LSB', 'CW', 'FM', 'FT8'};
            app.ModeDropDown.ValueChangedFcn = createCallbackFcn(app, @ModeDropDownValueChanged, true);
            app.ModeDropDown.FontSize = 15;
            app.ModeDropDown.Position = [304 224 68 28];
            app.ModeDropDown.Value = 'USB';

            % Create RSTLabel_3
            app.RSTLabel_3 = uilabel(app.Tab);
            app.RSTLabel_3.HorizontalAlignment = 'right';
            app.RSTLabel_3.FontSize = 15;
            app.RSTLabel_3.Position = [477 133 107 22];
            app.RSTLabel_3.Text = '己方序号(Num)';

            % Create SaveButton
            app.SaveButton = uibutton(app.Tab, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [557 25 108 38];
            app.SaveButton.Text = '保存(Save)';

            % Create ClearButton
            app.ClearButton = uibutton(app.Tab, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [25 25 108 38];
            app.ClearButton.Text = '清空缓存(Clear)';

            % Create Label_6
            app.Label_6 = uilabel(app.Tab);
            app.Label_6.HorizontalAlignment = 'center';
            app.Label_6.FontSize = 5;
            app.Label_6.Position = [391 81 252 34];
            app.Label_6.Text = '';

            % Show the figure after all components are created
            app.LoggerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = logger

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.LoggerUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.LoggerUIFigure)
        end
    end
end