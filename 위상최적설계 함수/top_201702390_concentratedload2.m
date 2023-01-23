%%%% A 99 LINE TOPOLOGY OPTIMIZATION CODE BY OLE SIGMUND, JANUARY 2000 %%%
%%%% CODE MODIFIED FOR INCREASED SPEED, September 2002, BY OLE SIGMUND %%%
function top_201702390_concentratedload2(nelx,nely,volfrac,penal,rmin);
% top_201702390_concentratedload2 함수 정의
% top(x 방향 요소의 수, y 방향 요소의 수, 몇 %의 질량을 사용, penalization power, 필터 사이즈)
% 이때 penalization power = 3으로 설정해 두는 것이 좋다.

% INITIALIZE(초기화 단계)
x(1:nely,1:nelx) = volfrac; % 'nely*nelx'크기의 행렬이면서 각 요소가 'volfrac'인 x를 정의
loop = 0; 
change = 1.; 

% START ITERATION
while change > 0.01  % change가 0.01이하로 떨어지기 전에는 계속 반복 
  loop = loop + 1;
  xold = x; % 초기 x를 저장해준다. 그래서 x'old'
% FE-ANALYSIS
  [U]=FE(nelx,nely,x,penal); % FE 함수 사용 (아래에 FE 함수가 정의되어 있다.)       
  % 함수 FE: [K][U]=[F] 
  % [k]:강성(N/m), [U]: 변위(m),  [F]: 힘(N) 
  
  % OBJECTIVE FUNCTION AND SENSITIVITY(gradient) ANALYSIS -> 목적함수와 그에 대한 gradient 구하기
  [KE] = lk; % lk 함수. 아래에 정의되어 있다.
  c = 0.;
  for ely = 1:nely
    for elx = 1:nelx
      n1 = (nely+1)*(elx-1)+ely; 
      n2 = (nely+1)* elx   +ely;
      Ue = U([2*n1-1;2*n1; 2*n2-1;2*n2; 2*n2+1;2*n2+2; 2*n1+1;2*n1+2],1);
      % U(displacement): global U.
      % Ue: U에서 각각의 요소의 자유도에 맞는 성분을 n1, n2를 사용해 뽑아낸 것.
      c = c + x(ely,elx)^penal*Ue'*KE*Ue;
      % 목적함수 c(strain energy)
      % 목적함수인 strain energy: 구조물 전체에 대한 값.
      % 각 요소의 strain energy를 구한 후, 그것들을 모두 더해 c에 저장.
      dc(ely,elx) = -penal*x(ely,elx)^(penal-1)*Ue'*KE*Ue; % dc: 목적함수의 gradient
    end
  end

% FILTERING OF SENSITIVITIES -> 목적함수의 gradient에 대한 필터. 필터의 크기를 지정해주는 rmin에 의하여 필터 성능이 결정  
  [dc]   = check(nelx,nely,rmin,x,dc); % 아래에 정의되어 있다. 
  % 최적화 알고리즘에 대입하기 전에 필터를 사용. 
  
% DESIGN UPDATE BY THE OPTIMALITY CRITERIA METHOD -> 목적함수인 c, c의 gradient인 dc, 제한조건인 volfrac을 최적화 알고리즘에 대입한다. 
  [x]    = OC(nelx,nely,x,volfrac,dc); 
% PRINT RESULTS -> while 문 한바퀴 돌 때마다 결과 출력됨.
  change = max(max(abs(x-xold))); % 새로운 설계변수와 그 전의 설계변수의 차의 절대값 중에서 가장 큰 값이 포함된 행 벡터에서 가장 큰 값으로 정의
  % 0.01 이하 일 때 최적화 끝

  disp([' It.: ' sprintf('%4i',loop) ' Obj.: ' sprintf('%10.4f',c) ...
       ' Vol.: ' sprintf('%6.3f',sum(sum(x))/(nelx*nely)) ...
        ' ch.: ' sprintf('%6.3f',change )]) % sprintf: 데이터 형식을 string형 또는 문자형 벡터로 지정
% PLOT DENSITIES  
  colormap(gray); imagesc(-x); axis equal; axis tight; axis off;pause(1e-6);
  % colormap(gray): 현재 Figure의 컬러맵을 gray로 지정된 컬러맵으로 선정
  % imagesc(-x): 현재 좌표축 대신 -x로 지정된 좌표축에 이미지 생성
  % axis equal: 각 축의 데이터 단위에 동일한 길이 사용
  % axis tight: 꼭 맞는 축 제한을 사용하여 값 반환
  % axis off: 좌표축 선과 배경 없이 플롯 표시
  % pause: 매트랩 실행을 일시적으로 중지
end 
%%%%%%%%%% OPTIMALITY CRITERIA UPDATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xnew]=OC(nelx,nely,x,volfrac,dc) % 입력 nelx,nely,x,volfrac,dc를 받고 출력 [xnew]를 반환하는 OC 함수 
% OC(Optimally Criteria): 여기서 사용하는  최적화 알고리즘 
l1 = 0; l2 = 100000; move = 0.2;
while (l2-l1 > 1e-4)
  lmid = 0.5*(l2+l1);
  xnew = max(0.001,max(x-move,min(1.,min(x+move,x.*sqrt(-dc./lmid)))));
  if sum(sum(xnew)) - volfrac*nelx*nely > 0;
    l1 = lmid;
  else
    l2 = lmid;
  end
end
%%%%%%%%%% MESH-INDEPENDENCY FILTER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dcn]=check(nelx,nely,rmin,x,dc)
dcn=zeros(nely,nelx);
for i = 1:nelx
  for j = 1:nely
    sum=0.0; 
    for k = max(i-floor(rmin),1):min(i+floor(rmin),nelx) % floor(X)는 행렬 X의 각 요소를 해당 요소보다 작거나 같은 가장 가까운 정수로 내림한다.
      for l = max(j-floor(rmin),1):min(j+floor(rmin),nely)
        fac = rmin-sqrt((i-k)^2+(j-l)^2);
        sum = sum+max(0,fac);
        dcn(j,i) = dcn(j,i) + max(0,fac)*x(l,k)*dc(l,k);
      end
    end
    dcn(j,i) = dcn(j,i)/(x(j,i)*sum);
  end
end
%%%%%%%%%% FE-ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [U]=FE(nelx,nely,x,penal) % FE 함수 정의
[KE] = lk; % 이래 정의되어 있는 함수이다. 
%{ 
1. 희소 행렬: 행렬의 값 대부분이 0으로 채워진 행렬 => 0 으로 채워진 부분까지 행렬로 표현하는 방법은 메모리의 낭비
2. sparse -> 값이 없는 성분을 빼고 저장하여 계산 속도 향상
  
  - sparse(A) -> 희소 행렬 A의 메모리를 줄여준다.
  - sparse(a,b) -> 행렬의 모든 요소가 0인 희소 형식의 m×n 행렬을 생성
%}

% sparse로 계산 속도 향상
K = sparse(2*(nelx+1)*(nely+1), 2*(nelx+1)*(nely+1)); % 강성 k. 모든 요소가 0인 희소 형식의 (총 자유도수)*(총 자유도수) 행렬
F = sparse(2*(nely+1)*(nelx+1),1); % 힘 F. 모든 요소가 0인 희소 형식의 (총 자유도수)*(1) 행렬
U = zeros(2*(nely+1)*(nelx+1),1); % 변위 U. (총 자유도수)*(1)의 크기인 영행렬.
for elx = 1:nelx % 'element x'가 1에서부터 number of element x 까지 1씩 증가 
  for ely = 1:nely % 'element y'가 1에서부터 number of element y 까지 1씩 증가
    n1 = (nely+1)*(elx-1)+ely; 
    n2 = (nely+1)* elx   +ely;
    edof = [2*n1-1; 2*n1; 2*n2-1; 2*n2; 2*n2+1; 2*n2+2; 2*n1+1; 2*n1+2]; 
    % 각 요소의 8개 자유도. 
    % 반복문 돌 때 요소 순서는 
    %{
    1  4  7  10  13...
    2  5  8  11
    3  6  9  12
    %}
    % edof: 자유도(dof) 요소
    K(edof,edof) = K(edof,edof) + x(ely,elx)^penal*KE; 
    % K(edof 요소, edof 요소)의 모든 경우의 수에 대해 위의 식을 수행
    % x(ely, elx)는 volfrac을 의미한다. 
    % K를 만드는 과정!
  end
end
% DEFINE LOADS AND SUPPORTS (HALF MBB-BEAM)

% 외부에서 작용하는 힘 정의(분포하중 + 집중하중) => 추진하고 있는 상황에서의 뒷발
F(2*(nely+1):2*(nely+1):2*((nelx+1)-nelx/4-1)*(nely+1),1) = 1;
F(2*((nelx+1)-nelx/4)*(nely+1),1) = 102; 
F(2*((nelx+1)-nelx/4)*(nely+1)+2*(nely+1):2*(nely+1):2*(nelx+1)*(nely+1),1) = 1;

% 고정된 자유도(맨 윗 노드들의 y요소들 + 맨 윗 노드들 중 처음 노드의 x 요소 + 맨 윗 노드들 중 마지막 노드의 x 요소)
fixeddofs   = [1, 2:2*(nely+1):2*(nelx)*(nely+1)-2*nely, 2*(nelx+1)*(nely+1)-2*nely-1, 2*(nelx+1)*(nely+1)-2*nely];

% 모든 자유도
alldofs     = [1:2*(nely+1)*(nelx+1)];

% 움직일 수 있는 자유도
freedofs    = setdiff(alldofs,fixeddofs); % setdiff: 두 배열의 차집합 -> 이를 이용해 움직일 수 있는 자유도 도출.

% SOLVING: freedofs에 대해서만 푼다.  
U(freedofs,:) = K(freedofs,freedofs) \ F(freedofs,:); % \: 좌측 나눗셈. 
% 행렬 A가 역행렬을 갖는 정방 행렬이면 선형 방정식 Ax=b 의 해 x를 구하기 위해 좌측 나눗셈(\)을 사용
U(fixeddofs,:)= 0;
%%%%%%%%%% ELEMENT STIFFNESS MATRIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [KE]=lk % 강성 요소 행렬 
E = 1.; 
nu = 0.3;
% ... : 현재 명령이 다음 라인까지 이어진다. 
% 라인이 끝나기 전에 3개 이상의 마침표를 사용하면 MATLAB에서 라인의 나머지 부분이 무시되고 다음 라인으로 이어진다. 
% -> 이 경우 현재 라인에서 3개의 마침표 다음에 오는 내용은 주석으로 처리.
k=[ 1/2-nu/6   1/8+nu/8 -1/4-nu/12 -1/8+3*nu/8 ... 
   -1/4+nu/12 -1/8-nu/8  nu/6       1/8-3*nu/8];
KE = E/(1-nu^2)*[ k(1) k(2) k(3) k(4) k(5) k(6) k(7) k(8)
                  k(2) k(1) k(8) k(7) k(6) k(5) k(4) k(3)
                  k(3) k(8) k(1) k(6) k(7) k(4) k(5) k(2)
                  k(4) k(7) k(6) k(1) k(8) k(3) k(2) k(5)
                  k(5) k(6) k(7) k(8) k(1) k(2) k(3) k(4)
                  k(6) k(5) k(4) k(3) k(2) k(1) k(8) k(7)
                  k(7) k(4) k(5) k(2) k(3) k(8) k(1) k(6)
                  k(8) k(3) k(2) k(5) k(4) k(7) k(6) k(1)]; % 8*8 행렬
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This Matlab code was written by Ole Sigmund, Department of Solid         %
% Mechanics, Technical University of Denmark, DK-2800 Lyngby, Denmark.     %
% Please sent your comments to the author: sigmund@fam.dtu.dk              %
%                                                                          %
% The code is intended for educational purposes and theoretical details    %
% are discussed in the paper                                               %
% "A 99 line topology optimization code written in Matlab"                 %
% by Ole Sigmund (2001), Structural and Multidisciplinary Optimization,    %
% Vol 21, pp. 120--127.                                                    %
%                                                                          %
% The code as well as a postscript version of the paper can be             %
% downloaded from the web-site: http://www.topopt.dtu.dk                   %
%                                                                          %
% Disclaimer:                                                              %
% The author reserves all rights but does not guaranty that the code is    %
% free from errors. Furthermore, he shall not be liable in any event       %
% caused by the use of the program.                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
