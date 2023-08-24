function cc = yellow_map(varargin)
    if isempty(varargin)
        npts = 256;
    else
        npts = varargin{1};
    end
    c_start = [1        1           0.9];
    c_end   = [0.82 0.82 0.1];
    cc = [linspace(c_start(1), c_end(1), npts)', ...
          linspace(c_start(2), c_end(2), npts)', ...
          linspace(c_start(3), c_end(3), npts)'];
end