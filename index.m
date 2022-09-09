M1 = xlsread('Matrix1.xls'); %Importing data for Matrix I
M2 = xlsread('Matrix2.xls'); %ratings 0-4 and NaN if movie not rated
M3 = xlsread('Matrix3.xls');

M1_ratings = prune_ratings(M1);
M2_ratings = prune_ratings(M2);
M3_ratings = prune_ratings(M3);

titles = '123';
means = [mean(M1_ratings), mean(M2_ratings), mean(M3_ratings)];
sems = [get_sem(M1_ratings), get_sem(M2_ratings), get_sem(M3_ratings)]

figure
set(gca,'xtick',1:3,'xticklabel',{'a','b','c'})
bar(1:3, means)
hold on
er = errorbar(means, sems);
er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 1;
xlabel('Matrix Movies');
ylabel('Average rating');
title('Average rating of Matrix movies (N = 1603)');

M_12 = [M1 M2];
nan_indices = find(isnan(M_12(:,1)) | isnan(M_12(:,2)));
M_12(nan_indices,:) = [];
fprintf("Size of M1-M2 matrix = %d\n", length(M_12))

cc = corrcoef(M_12);
fprintf("Pearson -elation between M1-M2 = %.4f\n", cc(1,2))

% Eligible raters are those who watched M1
raters = [M1 M2];
M1_watchers = find(isnan(raters(:,1)));
raters(M1_watchers,:) = [];

% Average M1 rating for those who watched M2
M_12_continuers = raters;
dropper_indices = find(isnan(raters(:,2)));
M_12_continuers(dropper_indices,:) = [];
continuers = M_12_continuers(:,1);
continuer_mean = mean(continuers);

% Average M1 rating for those who did NOT watch M2
M_12_droppers = raters;
continuer_indices = find(~isnan(raters(:,2)));
M_12_droppers(continuer_indices,:) = [];
droppers = M_12_droppers(:,1);
dropper_mean = mean(droppers);

[h, p_value] = ttest2(continuers, droppers);

fprintf("Average M1 rating for those who continued to M2 = %.4f\n", continuer_mean)
fprintf("Average M1 rating for those who did not continue to M2 = %.4f\n", dropper_mean)
fprintf("p = %d\n", p_value)
It makes sense that those who enjoyed M1 more were more likely to watch the sequel. A pleased viewer would hope to find a similar amount of enjoyment from the second movie as they did the first, while a displeased viewer would more frequently avoid another film that might induce the same displeasure as before.
10) Visualize the relationship between the ratings for Matrix I and II
in two dimensions by adding noise to points in both dimensions. The functions rand and size may be useful. Only add enough noise to visualize the data but not enough that you can't tell what point each was before adding noise. (e.g., if you add 0.8 to a rating of 3, you don't know whether it was originally 3 or 3.5). Use -1+noise for missing data so that it can also be plotted on the same scatterplot. Label your axes. When we visualize the data in this way, what are the some patterns that you can see in the data?
M1_data = [];
M2_data = [];

for i = 1:length(M1)
    if isnan(M1(i))
        M1_data(i) = -1 + noise();
    else
        M1_data(i) = M1(i) + noise();
    end
    if isnan(M2(i))
        M2_data(i) = -1 + noise();
    else
        M2_data(i) = M2(i) + noise();
    end
end

figure
scatter(M1_data, M2_data)
xlabel("M1 Ratings")
ylabel("M2 Ratings")
title("Scatter plot of M1 and M2 ratings")
There are a few marked patterns when visualizing the data with noise: 
1) The top left is largely whitespace, i.e. those who disliked M1 did not enjoy M2.
2) The graph demonstrates a positive correlation in which the highest concentration of points occurs in the top right, i.e. those who enjoyed M1 largely also enjoyed M2.
3) The thick box-like clump of points hovering over (-1, -1) reminds us that within this sample size, a sizable portion had not seen either movie.

N = 10;
corrcoefs = zeros(N, 1);

for n = 1:N
    temp = add_noise(M_12);
    cc = corrcoef(temp);
    corrcoefs(n) = cc(1,2);
end

fprintf("Pearson correlation between M1-M2 with noise: ");
corrcoefs
The Pearson correlation coefficients hover around .49 when noise is introduced, which is slightly less than the answer we found in #8. This makes sense because the introduction of noise slightly dilutes the accuracy and strength of the correlation.

coef_with_noise = mean(corrcoefs)
After closing Matlab, reopening it, and running my script two times, I have found that the average Pearson coefficients between M1 and M2 when noise is introduced were equivalent. Each time, the returned value was exactly 0.4920. My intuition behind this is whenever the Matlab shell is restarted, the rand() function is reset, i.e. the seed is reinitialized, and so it regenerates the same set of random numbers from the start. As a result, it produces the same noise and thus the same Pearson coefficients.

M_123 = [M1 M2 M3];
nan_indices = find(isnan(M_123(:,1)) | isnan(M_123(:,2)) | isnan(M_123(:,3)));
M_123(nan_indices,:) = [];

impact = [1; .4; .4^2];
happiness = M_123 * impact;
avg_happiness = mean(happiness)

rev_happiness = M_123 * flip(impact);
avg_rev_happiness = mean(rev_happiness)

figure
hist(rev_happiness, 40)
xlabel("Happiness")
ylabel("Number of marathoners")
title("Final happiness after backwards movie marathon")
The thing that's unusual about this graph is that the highest bin count of all appears at the highest happiness point. In other words, we find the highest concentration of ecstatic people when they watch the trilogy in reverse. My intuition behind this is that we are finding this result in the very limited sample size of those who watched ALL 3 Matrix movies. These diehard Matrix fans have the highest adoration for the trilogy overall, and are the most likely to be pleased by the last one because they love the whole franchise so much.

function s = get_sem(M)
    s = std(M) / (sqrt(length(M)));
end

function r = prune_ratings(M)
    r = [];
    i = 1;
    for j = 1 : length(M)
        if ~isnan(M(j))
           r(i) = M(j);
           i = i + 1;
        end
    end
end

function m = add_noise(M)
    m = M;
    [r,c] = size(M);
    for i = 1:r
        for j = 1:c
            m(i,j) = m(i,j) + noise();
        end
    end
end

function r = noise()
    r = (.25 - -.25) .* rand(1, 1) -.25;
end
