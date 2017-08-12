function [L,edges,edgeRates,edgeJumps] = getRateMat_lattice( nodes, isFree, ghParams )
% assumes lattice structure
tic

dim = ghParams.dim;
diagJumps = ghParams.diagJumps;

freeInds = isFree > 0;
nFree = sum(freeInds(:));

if dim == 2
    nbrShifts = [ 1  0; -1  0;...
                  0  1;  0 -1 ];
    if diagJumps
        nbrShifts = [nbrShifts;...
                     1  1;...
                     1 -1;...
                    -1  1;...
                    -1 -1 ];
    end
end

if dim == 3
    nbrShifts = [ 1  0  0;...
                 -1  0  0;...
                  0  1  0;...
                  0 -1  0;...
                  0  0  1;...
                  0  0 -1];
    if diagJumps
        nbrShifts = [nbrShifts;...
                     1  1  0;...
                     1 -1  0;...
                    -1  1  0;...
                    -1 -1  0;...
                     1  0  1;...
                     1  0 -1;...
                    -1  0  1;...
                    -1  0 -1;...
                     0  1  1;...
                     0  1 -1;...
                     0 -1  1;...
                     0 -1 -1];
    end
end

numNbrs = size(nbrShifts,1);

edgeStart = repmat(isFree(freeInds),numNbrs,1);
edgeEnd = zeros(nFree*numNbrs,1);
edgeRates = zeros(nFree*numNbrs,1);

for i = 1:numNbrs
    
    shift = nbrShifts(i,:);
    % shifting by [i,j,k] gives the neighbor: site + i*e_1 + j*e_2 + k*e_3
    nbrInds = circshift(isFree,shift);
    nonzeroRate = logical(isFree.*nbrInds);
    
    if diagJumps == 2
        isNbrFree{i} = nonzeroRate;
    end
    nonzeroRate = nonzeroRate(freeInds);
    
    nodeNbrs = nodes - ghParams.h*shift;
    curEdgeRates = rate_lattice(nodes,nodeNbrs,ghParams).*nonzeroRate;

    inds = 1 + (i-1)*nFree:i*nFree;
    edgeEnd(inds) = nbrInds(freeInds);
    edgeRates(inds) = curEdgeRates;
end

if strcmpi(ghParams.geometry,'circleSlowdown')
    % Slows all rates of edges starting or ending in square
    delta = ghParams.rateCoeffs.delta;
    ctr = ghParams.ctr;
    
    nodesInObs = find(sqrt(sum((nodes - ctr).^2,2)) <= ghParams.R);
    slowedEdges = or(ismember(edgeStart,nodesInObs),ismember(edgeEnd,nodesInObs));
    edgeRates(slowedEdges) = edgeRates(slowedEdges)*delta;
elseif strcmpi(ghParams.geometry,'squareSlowdown')
    % Slows all rates of edges starting or ending in square
    delta = ghParams.rateCoeffs.delta;
    
    relCoords = nodes - ghParams.ctr;
    nodesInObs = find(all(abs(relCoords) < ghParams.rho/2,2));
    
    slowedEdges = or(ismember(edgeStart,nodesInObs),ismember(edgeEnd,nodesInObs));
    edgeRates(slowedEdges) = edgeRates(slowedEdges)*delta;
elseif strcmpi(ghParams.geometry,'squareBonding')
    % Slows all rates leaving nodes that are within dist
    delta = ghParams.rateCoeffs.delta;
    dist = ghParams.rateCoeffs.dist;
    
    relCoords = nodes - ghParams.ctr;
    nodesAtBdy = find(all(abs(relCoords) < (ghParams.rho/2 + dist),2));
    
    slowedEdges = ismember(edgeStart,nodesAtBdy);
    edgeRates(slowedEdges) = edgeRates(slowedEdges)*delta;
elseif strcmpi(ghParams.geometry,'squareBdyRepel')
    % Slows all rates from nodes at boundary to nodes not at boundary
    delta = ghParams.rateCoeffs.delta;
    dist = .75*ghParams.h;
    
    relCoords = nodes - ghParams.ctr;
    nodesAtBdy = all(abs(relCoords) < (ghParams.rho/2 + dist),2);
    nodesNotAtBdy = ~nodesAtBdy;
    
    nodesAtBdy = find(nodesAtBdy);
    nodesNotAtBdy = find(nodesNotAtBdy);
    
    acceleratedEdges = ismember(edgeStart,nodesAtBdy) & ismember(edgeEnd,nodesNotAtBdy);
    edgeRates(acceleratedEdges) = edgeRates(acceleratedEdges)*delta;
elseif strcmpi(ghParams.geometry,'squareBdyAttract')
    % Increase all rates from nodes not at boundary to nodes at boundary
    delta = ghParams.rateCoeffs.delta;
    dist = .75*ghParams.h;
    
    relCoords = nodes - ghParams.ctr;
    nodesAtBdy = all(abs(relCoords) < (ghParams.rho/2 + dist),2);
    nodesNotAtBdy = ~nodesAtBdy;
    
    nodesAtBdy = find(nodesAtBdy);
    nodesNotAtBdy = find(nodesNotAtBdy);
    
    acceleratedEdges = ismember(edgeStart,nodesNotAtBdy) & ismember(edgeEnd,nodesAtBdy);
    edgeRates(acceleratedEdges) = edgeRates(acceleratedEdges)*delta;
end
%% set up P

validInds = edgeRates > 0;
edgeStart = edgeStart(validInds);
edgeEnd = edgeEnd(validInds);
edgeRates = edgeRates(validInds);

L = sparse(edgeStart,edgeEnd,edgeRates);
L = L-diag(sum(L,2));

edges = [edgeStart,edgeEnd];

edgeJumps = nodes(edges(:,2),:) - nodes(edges(:,1),:);
inds = abs(edgeJumps) > .5;
edgeJumps(inds) = edgeJumps(inds) - sign(edgeJumps(inds));

time = toc;
fprintf('Calculated rate matrix in %.1f seconds.\n',time);

end
