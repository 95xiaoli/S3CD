function pred = fine_proc(A, Y, weight_mat, lambda1)
W = (eye(size(A',1)) + lambda1*(A'*weight_mat*A)) \ (lambda1*(A'*weight_mat*Y));
pred = A*W;

end