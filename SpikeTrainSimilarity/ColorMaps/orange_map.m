function cc = orange_map(varargin)
    if isempty(varargin)
        npts = 256;
    else
        npts = varargin{1};
    end
    c_start = [1  0.8  0.6];
    c_end   = [0.9804 0.5137 0.2039];
    cc = [linspace(c_start(1), c_end(1), npts)', ...
          linspace(c_start(2), c_end(2), npts)', ...
          linspace(c_start(3), c_end(3), npts)'];
end