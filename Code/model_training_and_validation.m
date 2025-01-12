%% Feature Matrix Code

X = [shuffled_table.kurtosis, shuffled_table.domfreq]; % Feature matrix
Y = shuffled_table.Label;

%% Augmentated Feature Matrix

X = [shuffled_table_2.kurtosis, shuffled_table_2.domfreq, shuffled_table_2.crest]; % Feature matrix
Y = shuffled_table_2.Label;

%% Splitting the data into training and testing

cv = cvpartition(Y, 'Holdout', 0.3);
X_train = X(training(cv), :);
Y_train = Y(training(cv));
X_test = X(test(cv), :);
Y_test = Y(test(cv));

%% Training a decission tree

decisionTreeModel = fitctree(X_train, Y_train);

%View the tree structure
%view(decisionTreeModel, 'Mode', 'graph');

% Training a random forest with 100 trees
randomForestModel = TreeBagger(100, X_train, Y_train, ...
    'Method', 'Classification', ...
    'OOBPrediction', 'On', ...
    'OOBPredictorImportance', 'On');

view(randomForestModel.Trees{1}, 'Mode', 'graph');
%View out-of-bag error plot (optional)
%figure;
%obbErrorPlot(randomForestModel);

%% Prediction Comparison of both models

% Decision Tree Prediction
Y_pred_tree = predict(decisionTreeModel, X_test);
accuracy_tree = sum(Y_pred_tree == Y_test) / length(Y_test);
disp(['Decision Tree Accuracy: ', num2str(accuracy_tree)]);

% Random Forest Prediction
[Y_pred_rf, ~] = predict(randomForestModel, X_test);
Y_pred_rf = str2double(Y_pred_rf); % Convert cell array to numeric
accuracy_rf = sum(Y_pred_rf == Y_test) / length(Y_test);
disp(['Random Forest Accuracy: ', num2str(accuracy_rf)]);

%% Get feature importance
featureImportance = randomForestModel.OOBPermutedPredictorDeltaError;

% Plot feature importance
figure;
bar(featureImportance);
xlabel('Feature');
ylabel('Importance');
title('Feature Importance');
set(gca, 'XTickLabel', {'Kurtosis', 'Dominant Frequency', 'Crest Factor'});

%% Getting the confusion Matrix Decision tree
confMat = confusionmat(Y_test, Y_pred_tree);
% Normalize the confusion matrix by rows (row-normalized)
confMatNormalized = (confMat ./ sum(confMat, 2))*100;

%displaying the confusion matrix
disp(confMatNormalized);

figure;
heatmap(confMatNormalized, 'Title', 'Confusion Matrix - Decission Tree', 'XLabel', 'Predicted Class', ...
    'YLabel', 'True Class');

%% Getting the confusion Matrix Random Forest
confMat = confusionmat(Y_test, Y_pred_rf);
% Normalize the confusion matrix by rows (row-normalized)
confMatNormalized = (confMat ./ sum(confMat, 2))*100;
%displaying the confusion matrix
disp(confMatNormalized);

figure;
heatmap(confMatNormalized, 'Title', 'Confusion Matrix - Random Forest', 'XLabel', 'Predicted Class', ...
    'YLabel', 'True Class');
