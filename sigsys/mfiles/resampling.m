function [x,w]=resampling(x,w,type)
%RESAMPLING resamples particles in the particle filter
%   [x,w]=resampling(x,w,type)
%
%   type  {'simple'}
%         'systematic'
%         'residual'
%         'stratified'
%
%   See: Resampling in particle filters
%        Jeroen D. Hol, T.B. Schon and F.Gustafsson
%        IEEE Nonlinear Statistical Signal Processing Workshop, 2006 


% Copyright Fredrik Gustafsson
%$ Revision: 21-Apr-2013  $

if nargin<3
    type='simple';
end
N=length(w);

if strncmp(type,'sys',3)
  u=([0:N-1]+rand(1))/N;
  wc=cumsum(w);
  [dum,ind1]=sort([u wc(:)']);
  ind2=find(ind1<=N);
  ind=ind2- (0:N-1);
  xnew=x(ind,:);
  wnew=ones(1,N)./N;
elseif strncmp(type,'sim1',4)
  u = cumprod(rand(1,N).^(1./[N:-1:1]));
  u = u(N:-1:1);
  wc = cumsum(w);
  wc=wc/wc(end);
  k=1;
  for i=1:N
     while(wc(k)<u(i))
        k=k + 1;
     end
     ind(i)=k;
  end
  xnew=x(ind,:);
  wnew=ones(1,N)./N;
elseif strncmp(type,'sim2',4)
  u = cumprod(rand(1,N).^(1./[N:-1:1]));
  u = u(N:-1:1);
  wc = cumsum(w);
  wc=wc/wc(end);
  [dum,ind1]=sort([u wc(:)']);
  ind2=find(ind1<=N);
  ind=ind2- (0:N-1);
  xnew=x(ind,:);
  wnew=ones(1,N)./N;
elseif strncmp(type,'sim',3)
  u = rand(N,1);
  wc = cumsum(w);
  wc=wc/wc(N);
  [dum,ind1]=sort([u;wc]);
  ind2=find(ind1<=N);
  ind=ind2-(0:N-1)';
  xnew=x(ind,:);
  wnew(1:N)=1/N;
elseif strncmp(type,'str',3)
  u=([0:N-1]+(rand(1,N)))/N;
  wc=cumsum(w);
  [dum,ind1]=sort([u wc(:)']);
  ind2=find(ind1<=N);
  ind=ind2- (0:N-1);
  xnew=x(ind,:);
  wnew=ones(1,N)./N;
elseif strncmp(type,'res',3)
  wa=N*w;
  nk=floor(wa);
  Nk=cumsum(nk);
  K=Nk(end);
  ind=zeros(1,K);
  k=1;
  for i=1:K
     while(Nk(k)<i)
        k=k + 1;
     end
     ind(i)=k;
  end
  wb=wa-nk;
  wb=wb/sum(wb);
  n=N-K;
  if n>0
    xnew=[x(:,ind), feval(rs,x,wb,n)];
  else
    xnew=x(:,ind);
  end
  wnew=ones(1,N)./N;
else
  error(['NL.PF Unknown sampling scheme: ',type])
end
x=xnew;
if isequal(size(w),size(wnew))
   w=wnew;
else
   w=wnew';
end
