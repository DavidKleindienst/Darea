function variable=shouldBeNumber(variableOld,hOb,floatAllowed,range)
%Checks whether hOb.String is a number
%If so updates variableOld (should be the number hOb.String corresponded to before user interaction)
%to hOb.string (converted to a number) and returns it as variable
%Otherwise reverts hOb.String to variableOld and returns variableOld unchanged
variable=variableOld;

if nargin<3
    floatAllowed=1;
end
if nargin<4
    range=NaN;
elseif numel(range)~=2 || ~isnumeric(range) || range(1)>range(2)
    error('range needs to be a numeric array with two numbers, lower bound and upper bound. Lower bound has to be smaller or equal upper bound');
end

number=str2double(hOb.String);

if isnan(number)
    %Entered somthing that's not a number
    hOb.String=num2str(variableOld);
    return;
end

if ~floatAllowed && mod(number,1)~=0
    %User entered a float, but floats are not allowed
    %so convert to int
    number = round(number);
    hOb.String=num2str(number);
end
if ~any(isnan(range)) && (range(1)>number || range(2)<number)
    %Number is outside of allowed range
    hOb.String=num2str(variableOld);
    return;
end

variable=number;    %User input was valid

