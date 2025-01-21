document.addEventListener('DOMContentLoaded', function () {
    const searchInput = document.getElementById('search-input');
    const searchResults = document.createElement('div');
    searchResults.className = 'search-results';
    document.querySelector('.search-container').appendChild(searchResults);

    let searchData = [];
    let debounceTimeout;

    // Get base URL from meta tag
    const getBaseUrl = () => {
        // First try to get from Jekyll config
        const baseUrl = document.querySelector('meta[name="baseurl"]')?.getAttribute('content') || '/recipes';
        return baseUrl;
    };

    // Fetch search index with correct path
    const baseUrl = getBaseUrl();
    fetch(`${baseUrl}/search.json`)
        .then(response => response.json())
        .then(data => {
            searchData = data;
            console.log('Search index loaded successfully'); // Debug log
        })
        .catch(error => console.error('Error loading search index:', error));

    // Handle search input
    searchInput.addEventListener('input', function () {
        clearTimeout(debounceTimeout);
        debounceTimeout = setTimeout(() => {
            const query = this.value.toLowerCase().trim();

            if (query.length < 2) {
                searchResults.style.display = 'none';
                return;
            }

            const results = searchData.filter(item => {
                const titleMatch = item.title.toLowerCase().includes(query);
                const categoryMatch = item.category.toLowerCase().includes(query);
                const descriptionMatch = item.description && item.description.toLowerCase().includes(query);
                return titleMatch || categoryMatch || descriptionMatch;
            }).slice(0, 5); // Limit to 5 results

            displayResults(results);
        }, 300); // Debounce delay
    });

    // Hide results when clicking outside
    document.addEventListener('click', function (e) {
        if (!searchResults.contains(e.target) && e.target !== searchInput) {
            searchResults.style.display = 'none';
        }
    });

    function displayResults(results) {
        if (results.length === 0) {
            searchResults.style.display = 'none';
            return;
        }

        searchResults.innerHTML = results.map(result => `
            <a href="${result.url}" class="search-result-item">
                <div class="search-result-title">${result.title}</div>
                <div class="search-result-meta">
                    ${result.category} • ${result.prep_time} prep • ${result.cook_time} cook
                </div>
            </a>
        `).join('');

        searchResults.style.display = 'block';
    }
});