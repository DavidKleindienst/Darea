function txt=reverse_eval(v,nest_level)
%REVERSE_EVAL - Created a string, that when evaluated, produces original construct.
%   REVERSE_EVAL(V) returns a string which when evaluated using EVAL, is
%     identical to V. Example:
%        v = load('-mat','my_figure.fig');
%        e = reverse_eval(v);
%        isequal(v,eval(e))
%     should return 1. Note that and NaN values within V will cause isequal
%     to return 0, but the evaluation will still be correct.
%   This currently does not support arrays whose number of dimensions are
%   greater than 2, or objects.
%
%   See also FIG2M.

% Note: The nest_level parameter is reserved for recursive calls from
% within this function.

% 2/3/2004 jaj Find empty structure problem
% 8/25/2004 jaj Add single; fix integer types

if nargin < 2
  nest_level = 0;
end

cls = class(v);
switch cls
  case 'double', fmt = '%.17g';
  case 'single', fmt = '%.9g';
  case 'logical', fmt = '%d';
  case 'int8', fmt = '%d';
  case 'uint8', fmt = '%u';
  case 'int16', fmt = '%d';
  case 'uint16', fmt = '%u';
  case 'int32', fmt = '%d';
  case 'uint32', fmt = '%u';
  case 'function_handle',
    if isempty(v)
      txt = sprintf('repmat(@funcptr,%d,%d)',size(v));
    else
      txt = '[';
      for r=1:size(v,1)
        row = [];
        for c=1:size(v,2)
          row = [row,'@',func2str(v(r,c)),','];
        end
        row(end) = ';';
        txt = [txt,row];
      end
      txt(end) = ']';
    end
  case 'char',
    if isempty(v)
      if sum(size(v)) == 0
        txt = '''''';
      else
        txt = sprintf('repmat(''a'',%d,%d)',size(v));
      end
    elseif size(v,1) == 1
      txt = sprintf('''%s''',strrep(v,'''','''''')); % single quote to two quotes
    else
      txt = sprintf('[');
      for r=1:size(v,1)
        txt = [txt,'''',strrep(v(r,:),'''',''''''),''' ']; % single quote to two quotes
        txt(end) = ';';
      end
      txt(end) = ']';
    end
  case 'cell',
    txt = '{';
    if isempty(v)
      txt = '{}';
    end
    for r=1:size(v,1)
      row = [];
      for c=1:size(v,2)
        row = [row,reverse_eval(v{r,c},nest_level+1),','];
      end
      row(end) = ';';
      txt = [txt,row];
    end
    txt(end) = '}';
  case 'struct',
    fnames = fieldnames(v);
    if isempty(fnames)
      % jaj 3/1/2004
      txt = ['repmat(struct,',reverse_eval(size(v)),')'];
    elseif prod(size(v)) == 0
      % jaj 3/1/2004
      temp=[fnames,repmat({'[]'},size(fnames))]';
      txt = ['struct(',sprintf('''%s'',%s,',temp{:})];
      txt(end) = ')';
      txt = sprintf('repmat(%s,%s)',txt,reverse_eval(size(v)));
    else
      txt = 'struct(';
      for ii=1:length(fnames)
        fld = fnames{ii};
        v2 = reshape({v.(fld)},size(v));
        txt = [txt,sprintf('''%s'',%s,',fld,reverse_eval(v2,nest_level+1))];
        end_position = length(txt)-1;
        txt = [txt,'...',10,repmat('  ',1,nest_level)];
      end
      txt = [txt(1:end_position),')'];
    end
  otherwise,
    fprintf('<Unknown_class_%s>',cls)
end

if isnumeric(v) || islogical(v)
  % Convert to double
  v = double(v);
  if isempty(v)
    if sum(size(v)) == 0
      txt = '[]';
    else
      txt = sprintf('repmat(1,%d,%d)',size(v));
    end
  elseif numel(v) == 1
    txt = sprintf(fmt,v);
  else
    txt = sprintf('[');
    % Format each row
    for r=1:size(v,1)
      row = sprintf([fmt,' '],v(r,:));
      txt = [txt,row];
      txt(end) = ';';
    end
    txt(end) = ']';
  end
  % Add re-cast to correct numeric type
  if ~strcmp(cls,'double')
    txt = sprintf('%s(%s)',cls,txt);
  end
end

try
  vcheck = eval(txt);
  % Comment the following because any NaN will cause apparent failure
%   if ~isequal(v,vcheck);
%      warning('Difference evaluating reverse expression (software error in this function)')
%   end
catch
  warning('Error evaluating reverse expression (software error in this function)')
end

