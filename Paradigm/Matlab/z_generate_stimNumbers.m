function frequency_matrix = z_generate_stimNumbers(desired_sum, spacing)

    % Parameters
    mu = 0;                  % Mean of the normal distribution
    sigma = 1;               % Standard deviation of the normal distribution
    rows = 3;                % Number of rows in the matrix
    cols = 3;                % Number of columns in the matrix
    %desired_sum = 240;       % Fixed total sum
    %spacing = 1.5;
    % Number of frequencies
    n = rows * cols;
    
    % Define equally spaced points over ±3 standard deviations
    x = linspace(mu - spacing*sigma, mu + spacing*sigma, n);
    
    % Evaluate the normal distribution's PDF at these points
    pdf_values = normpdf(x, mu, sigma);
    
    % Normalize the PDF values to sum to the desired sum
    scaled_values = pdf_values / sum(pdf_values) * desired_sum;
    
    % Round to nearest multiples of 4
    rounded_values = round(scaled_values / 4) * 4;
    
    % Adjust the sum to match the desired total
    current_sum = sum(rounded_values);
    difference = desired_sum - current_sum;
    
    % Adjust the frequencies in steps of 4
    if difference > 0
        % Increment the largest values until the sum matches
        for i = 1:(difference / 4)
            [~, idx] = max(mod(scaled_values, 4)); % Find the most deserving fractional part
            rounded_values(idx) = rounded_values(idx) + 4;
        end
    elseif difference < 0
        % Decrement the smallest values until the sum matches
        for i = 1:abs(difference / 4)
            [~, idx] = min(mod(scaled_values, 4)); % Find the least deserving fractional part
            rounded_values(idx) = rounded_values(idx) - 4;
        end
    end
    
    % Reshape into the desired matrix dimensions
    frequency_matrix = reshape(rounded_values, rows, cols);

    % Display results
    % disp('Frequency matrix (all divisible by 4):');
    % disp(frequency_matrix);
    % disp('Sum of frequencies:');
    % disp(sum(frequency_matrix, 'all'));
end
