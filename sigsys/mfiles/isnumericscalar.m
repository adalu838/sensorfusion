function ok=isnumericscalar(x)
%ISNUMERICSCALAR tests if the argument is numeric and scalar
%
% ok=isnumscalar(x)

% Copyright Fredrik Gustafsson
%$ Revision: 21-Apr-2013  $

ok = isnumeric(x) && isscalar(x);
