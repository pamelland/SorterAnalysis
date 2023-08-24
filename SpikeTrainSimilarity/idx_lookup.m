function idx = idx_lookup(list1, query)

% assumes list1 is sorted and query is sorted
list1 = list1(:);
query = query(:);

idx = find( ismember(list1, query) );
    
end