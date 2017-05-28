% MAC0420 - EP2
%
% Arthur Coser Marinho               NUSP: 7210629 
% Ludmila Ferreira Vicente e Silva   NUSP: 7557136
%
%! /bin/octave -qf

% dados os parâmetros para v e a malha f definimos v com os coeficientes de cada índice i,j
function retval = constroiv_bilinear (nx, ny, ax, bx, ay, by, f)
	B = inv([
		1, 0, 0, 0;
		1, 0, 1, 0;
		1, 1, 0, 0;
		1, 1, 1, 1;
	]);
	v = [];
	for i = 1:nx
		for j = 1:ny
			% a = [];
			% a(1,1) = f(i,j);
			% a(1,2) = f(i,j+1) - a(1,1);
			% a(2,1) = f(i+1,j) - a(1,1);
			% a(2,2) = f(i+1,j+1) - a(1,1) - a(1,2) - a(2,1);
			% v = [v; vec(a)'];
			% de modo mais fácil, calculamos os coeficientes com a operação matricial abaixo:
			A = B * [f(i,j), f(i,j+1), f(i+1,j), f(i+1,j+1)]';
			v = [v; A'];
		endfor
	endfor
	retval = v;
endfunction

% dados os parâmetros para v e a malha f definimos v com os coeficientes de cada índice i,j
function retval = constroiv_bicubica (nx, ny, ax, bx, ay, by, f, dx, dy, dxy)
	hx = (bx - ax) / nx;
	hy = (by - ay) / ny;
	B  = [1, 0, 0, 0; 0, 0, 1, 0; -3, 3, -2, -1; 2, -2, 1, 1];
	Bt = B';
	v = [];
	for i = 1:nx
		for j = 1:ny
			xi = ax + i * hx;
			yj = ay + j * hy;
			C = [ 
				f(i, j), f(i, j+1), dy(i, j), dy(i, j+1);
				f(i+1,j), f(i+1, j+1), dy(i+1, j), dy(i+1, j+1);
				dx(i, j), dx(i, j+1), dxy(i, j), dxy(i, j+1);
				dx(i+1,j), dx(i+1, j+1), dxy(i+1, j), dxy(i+1, j+1);
			];
			A = B * C * Bt;
		endfor
		v = [v; vec(A)'];
	endfor
	retval = v;
endfunction

% dados um par x, y e os parâmetros de v, devolvemos o valor de v(x,y) interpolado
function retval = avaliav_bilinear (x, y, v, nx, ny, ax, bx, ay, by)
	% se estiver fora do intervalo, retorna null
	if (x < ax || x > bx || y < ay || y > by)
		printf('Valor fora do intervalo\n');
		retval = null;
		return;
	endif

	% acha i e j para definir o intervalo que x e y pertencem
	hx = (bx - ax) / nx;
	hy = (by - ay) / ny;

	xi = ax;
	i = 0;
	while (xi + hx < x)
		xi += hx;
		i++;
	endwhile

	yj = ay;
	j = 0;
	while (yj + hy < y)
		yj += hy;
		j++;
	endwhile

	% acha o índice na matriz contendo os coeficientes de v
	k = i * ny + j + 1;

	% calcula s
	s = [1, (x - xi)/hx] * [v(k,1), v(k,2); v(k,3), v(k,4)] * [1; (y - yj)/hy];
	retval = s;
endfunction

arg_list = argv ();
f_filename = arg_list{1};
m = str2num(arg_list{2});

% lê o arquivo com a malha da função
f = dlmread(f_filename);
nmax = 200;

nx = nmax / m; ny = nmax / m; ax = -4; bx = 4; ay = -4; by = 4;
v = constroiv_bilinear(nx, ny, ax, bx, ay, by, f(1:m:end,1:m:end));

hx = (bx - ax) / nmax;
hy = (by - ay) / nmax;
for i = 1:nmax
	for j = 1:nmax
		xi = ax + (i-1) * hx;
		yj = ay + (j-1) * hy;
		s(i,j) = avaliav_bilinear(xi, yj, v, nx, ny, ax, bx, ay, by);
		e(i,j) = abs(f(i,j) - s(i,j));
	endfor
endfor

% verificando o erro
hx = (bx - ax) / nx
hy = (by - ay) / ny
e_max = max(vec(e(2:end-1,2:end-1))) % o erro na borda está maior que o normal, não identificamos o motivo

% normaliza s para a imagem
s -= min(vec(s));
s /= max(vec(s));
imwrite(s, 'imagem.png');

% plot 3D com o f - s
mesh(2:nmax-1, 2:nmax-1, e(2:end-1,2:end-1));
input('');

% imwrite(f(1:end,1:end),'f1');

% v = constroiv_bilinear(nx, ny, ax, bx, ay, by, f);
% avaliav_bilinear(0.4, -0.4, v, nx, ny, ax, bx, ay, by, f)
% avaliav_bilinear(0.33, 0.12, v, nx, ny, ax, bx, ay, by, f)
% avaliav_bilinear(-0.47, -0.91, v, nx, ny, ax, bx, ay, by, f)
