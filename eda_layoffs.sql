-- Exploratory Data Analysis

SELECT * 
FROM layoffs_staging2;

-- MAX total_laid_off and MAX percentage_laid_off
SELECT MAX(total_laid_off) AS Max_Total_Laid_Off, MAX(percentage_laid_off) AS Max_Percentage_Laid_Off
FROM layoffs_staging2;

-- Rows where percentage_laid_off = '1'
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = '1'
ORDER BY total_laid_off DESC;

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = '1'
ORDER BY funds_raised_millions DESC;

-- Total layoffs per company
SELECT company, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY company
ORDER BY Total_Laid_Off DESC;

-- Date range
SELECT MIN(TRY_CAST([date] AS DATE)) AS Min_Date, MAX(TRY_CAST([date] AS DATE)) AS Max_Date
FROM layoffs_staging2;

-- Total layoffs per industry
SELECT industry, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY industry
ORDER BY Total_Laid_Off DESC;

-- Total layoffs per country
SELECT country, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY country
ORDER BY Total_Laid_Off DESC;

-- Yearly total layoffs
SELECT YEAR(TRY_CAST([date] AS DATE)) AS Year, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY YEAR(TRY_CAST([date] AS DATE))
ORDER BY Year DESC;

-- Total layoffs per stage
SELECT stage, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY stage
ORDER BY Total_Laid_Off DESC;

-- Monthly total layoffs by extracting month substring
SELECT SUBSTRING([date], 6, 2) AS Month, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
WHERE SUBSTRING([date], 6, 2) IS NOT NULL
GROUP BY SUBSTRING([date], 6, 2)
ORDER BY Month ASC;

-- Monthly total layoffs by year-month substring
SELECT SUBSTRING([date], 1, 7) AS Year_Month, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
WHERE SUBSTRING([date], 1, 7) IS NOT NULL
GROUP BY SUBSTRING([date], 1, 7)
ORDER BY Year_Month ASC;

-- Rolling total of layoffs by Year-Month
WITH Rolling_Total AS
(
    SELECT SUBSTRING([date], 1, 7) AS Year_Month, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING([date], 1, 7) IS NOT NULL
    GROUP BY SUBSTRING([date], 1, 7)
)
SELECT Year_Month, total_off,
       SUM(total_off) OVER (ORDER BY Year_Month) AS rolling_total
FROM Rolling_Total;

-- Total layoffs per company and year
SELECT company, YEAR(TRY_CAST([date] AS DATE)) AS Year, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY company, YEAR(TRY_CAST([date] AS DATE))
ORDER BY Total_Laid_Off DESC;

-- Top 5 companies by layoffs per year
WITH Company_Year AS
(
    SELECT company, YEAR(TRY_CAST([date] AS DATE)) AS Year, SUM(total_laid_off) AS Total_Laid_Off
    FROM layoffs_staging2
    GROUP BY company, YEAR(TRY_CAST([date] AS DATE))
),
Company_Year_Rank AS
(
    SELECT *, DENSE_RANK() OVER (PARTITION BY Year ORDER BY Total_Laid_Off DESC) AS Ranking
    FROM Company_Year
    WHERE Year IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
ORDER BY Year DESC, Ranking ASC;
