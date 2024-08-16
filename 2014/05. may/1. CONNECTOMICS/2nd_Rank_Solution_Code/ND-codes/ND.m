function mat_nd=ND(mat,varargin)

%--------------------------------------------------------------------------
% ND.m: network deconvolution
%--------------------------------------------------------------------------
%
% DESCRIPTION:
%
% USAGE:
%    mat_nd = ND(mat)
%    mat_nd = ND(mat,beta)
%    mat_nd = ND(mat,beta,alpha,control)
%
%
% INPUT ARGUMENTS:
% mat           Input matrix, if it is a square matrix, the program assumes
%               it is a relevance matrix where mat(i,j) represents the similarity content
%               between nodes i and j. If it is not a square matrix, the program assumes
%               that it is an expression matrix and computes mutual information (MI)
%               between variables. Elements of matrix are
%               non-negative.

% optional parameters:
% beta          Scaling parameter, the program maps the largest absolute eigenvalue
%               of the direct dependency matrix to beta. It should be
%               between 0 and 1.
% alpha         fraction of edges of the observed dependency matrix to be kept in
%               deconvolution process.
% control       if 0, displaying direct weights for observed
%               interactions, if 1, displaying direct weights for both observed and
%               non-observed interactions.
%
% OUTPUT ARGUMENTS:

% mat_nd        Output deconvolved matrix (direct dependency matrix). Its components
%               represent direct edge weights of observed interactions.
%               Choosing top direct interactions (a cut-off) depends on the application and
%               is not implemented in this code.

% To apply ND on regulatory networks, follow steps explained in Supplementary notes
% 1.4.1 and 2.1 and 2.3 of the paper.
% In this implementation, input matrices are made symmetric.


% LICENSE: MIT-KELLIS LAB

% AUTHORS:
%    Algorithm was programmed by Soheil Feizi.
%    Paper authors are S. Feizi, D. Marbach,  M. Médard and M. Kellis
%
% REFERENCES:
%   For more details, see the following paper:
%    Network Deconvolution as a General Method to Distinguish
%    Direct Dependencies over Networks
%    By: Soheil Feizi, Daniel Marbach,  Muriel Médard and Manolis Kellis
%    Nature Biotechnology
%


%**************************************************************************
% loading scaling and thresholding parameters

nVarargs = length(varargin);

if nVarargs==0
    % default parameters
    beta = 0.9;
    alpha = 1;
    control=0;
elseif nVarargs==1
    beta = varargin{1};
    if beta>=1 | beta<=0
        disp('error: beta should be in (0,1)');
    end
    alpha = 1;
    control=0;
elseif nVarargs==2
    control=0;
    beta = varargin{1};
    alpha = varargin{2};
    if beta>=1 | beta<=0
        disp('error: beta should be in (0,1)');
    end
    if alpha>1 | alpha<=0
        disp('error: alpha should be in (0,1]');
    end
elseif nVarargs==3
    
    beta = varargin{1};
    alpha = varargin{2};
    control = varargin{3};
    if beta>=1 | beta<=0
        disp('error: beta should be in (0,1)');
    end
    if alpha>1 | alpha<=0
        disp('error: alpha should be in (0,1]');
    end
else
    disp('error:too many input arguments')
end

%***********************************
% computing MI if the input matrix is the expression matrix

if size(mat,1) == 0
    disp('error: input matrix is empty')
elseif size(mat,1) == size(mat,2)
    % proceed without MI computation
    disp('input matrix is a relevance network')
    
elseif size(mat,1) ~= size(mat,2)
    
    disp('input matrix is an expression array')
    disp('computing MI...')
    % MI computation is required
    % spline interpolation with degree 3 and bin sizes 10
    
    mat = mi(mat,10,3); % 10 is the number of bins and 3 is the degree of spline
end

%***********************************
% processing the inut matrix
% linearly mapping the input matrix to be between 0 and 1

if min(min(mat)) ~= max(max(mat))
    mat = (mat-min(min(mat)))./(max(max(mat))-min(min(mat)));
else
    disp('the input matrix is a constant matrix')
end

% diagonal values are filtered

n = size(mat,1);
mat = mat.*(1-eye(n));

% thresholding the input matrix


y=quantile(mat(:),1-alpha);
mat_th=mat.*(mat>=y);

% making the matrix symetric if already not
mat_th = (mat_th+mat_th')/2;

%***********************************
% eigen decomposition
%disp('decomposition and deconvolution...')
[U,D] = eig(mat_th);


lam_n=abs(min(min(diag(D)),0));
lam_p=abs(max(max(diag(D)),0));

m1=lam_p*(1-beta)/beta;
m2=lam_n*(1+beta)/beta;
m=max(m1,m2);


%network deconvolution
for i = 1:size(D,1)
    D(i,i) = (D(i,i))/(m+D(i,i));
end
mat_new1 = U*D*inv(U);

%***********************************
% displying direct weights
if control==0
    ind_edges = (mat_th>0)*1.0;
    ind_nonedges = (mat_th==0)*1.0;
    m1 = max(max(mat.*ind_nonedges));
    m2 = min(min(mat_new1));
    mat_new2 = (mat_new1+max(m1-m2,0)).*ind_edges+(mat.*ind_nonedges);
elseif control==1
    m2 = min(min(mat_new1));
    mat_new2 = (mat_new1+max(-m2,0));
end


%***********************************
% linearly mapping the deconvolved matrix to be between 0 and 1

m1 = min(min(mat_new2));
m2 = max(max(mat_new2));
mat_nd = (mat_new2-m1)./(m2-m1);





