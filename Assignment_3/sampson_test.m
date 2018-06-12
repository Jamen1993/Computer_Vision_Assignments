% Beliebige Fundamentalmatrix
F = [0.594424990714701	0.659838958652581 0.401394151818037;
     0.507757017614864	0.553410686745762 0.0844450848561230;
     0.202284192120169	0.251487436638534 0.817684994266377];

% Beliebige homogene Pixelkoordinaten
x1_pixel = [75	494	125	267	178	165;
            192	228	299	295	39	387;
            1	1	1	1	1	1];
x2_pixel = [215	173	382	303	131	151;
            157	21	439	257	150	121;
            1	1	1	1	1	1];

sd = sampson_dist(F, x1_pixel, x2_pixel)
