function compress(f, k)
  [h, w, d] = size(f);
  
  f = f(1:(k+1):h, 1:(k+1):w,:);
  imwrite (f, 'compress.png');
endfunction

