%! /bin/octave -qf

nmax = 200; 

nx = nmax; ny = nmax; ax = -4; bx = 4; ay = -4; by = 4;

hx = (bx - ax) / nx;
hy = (by - ay) / ny;
for i = 1:nx+1
	for j = 1:ny+1
		xi = ax + (i-1) * hx;
		yj = ay + (j-1) * hy;
		f1(i, j) = xi ^ 2 - yj ^ 2;
		f2(i, j) = xi + yj + 1;
		f3(i, j) = xi ^ 3 - 2 * xi * yj + 1;
		f4(i, j) = cos(yj) + sin(xi);
		f5(i, j) = 3 * xi * sin(xi) - 4 * yj * cos(xi);
		f6(i, j) = xi / 2 * yj - yj^4 -1;
	endfor
endfor

dlmwrite('f1.dat', f1);
dlmwrite('f2.dat', f2);
dlmwrite('f3.dat', f3);
dlmwrite('f4.dat', f4);
dlmwrite('f5.dat', f5);
dlmwrite('f6.dat', f6);
