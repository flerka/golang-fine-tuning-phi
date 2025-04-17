import requests

ACCESS_TOKEN = ''
HEADERS = {
    'Authorization': f'token {ACCESS_TOKEN}',
    'Accept': 'application/vnd.github.v3+json'
}

BASE_URL = 'https://api.github.com/search/repositories'
QUERY = 'language:Go size:>=1000 license:apache-2.0 license:mit'
DESCENDING_FILE = 'repositories_desc.txt'
ASCENDING_FILE = 'repositories_asc.txt'
COMBINED_FILE = 'repositories_combined.txt'

# count the number of lines to reduce API calls
def count_lines_in_file(file_path):
    try:
        with open(file_path, 'r') as file:
            return len(file.readlines())
    except FileNotFoundError:
        return 0

# get one page of repositories from API
# it returns 100 repositories per page
def fetch_repositories_page(query, order, page, per_page=100):
    params = {
        'q': query,
        'sort': 'stars',
        'order': order,
        'per_page': per_page,
        'page': page
    }

    response = requests.get(BASE_URL, headers=HEADERS, params=params)
    if response.status_code != 200:
        print(f'Error: {response.status_code} - {response.json().get("message", "No message")}')
        return []
    data = response.json()
    return data.get('items', [])

# write to file
def write_repositories_to_file(file, repositories):
    for repo in repositories:
        file.write(repo['clone_url'] + '\n')

# fetches repos with pagination ans saves to file
def fetch_and_write_repositories(query, order, file_path, existing_count=0, per_page=100):
    repos_count = existing_count
    page = (existing_count // per_page) + 1
    with open(file_path, 'a') as file:
        while True:
            print(f'fetching page {page} in {order} order')
            repositories = fetch_repositories_page(query, order, page, per_page)
            if not repositories:
                break
            write_repositories_to_file(file, repositories)
            repos_count += len(repositories)
            if len(repositories) < per_page:
                break
            page += 1
    return repos_count - existing_count

# due to limitations of the api we need to combine 
# repos in asc and desc order to receive full list
def deduplicate_and_combine_files(desc_file, asc_file, combined_file):
    seen = set()
    with open(combined_file, 'w') as combined:
        with open(desc_file, 'r') as desc:
            for line in desc:
                if line not in seen:
                    combined.write(line)
                    seen.add(line)
        with open(asc_file, 'r') as asc:
            for line in asc:
                if line not in seen:
                    combined.write(line)
                    seen.add(line)

def main():
    # count existing repos
    existing_desc_count = count_lines_in_file(DESCENDING_FILE)
    existing_asc_count = count_lines_in_file(ASCENDING_FILE)

    # get repos urls
    fetch_and_write_repositories(QUERY, 'desc',
                DESCENDING_FILE, existing_count=existing_desc_count)
    print(f'fetching in descending order is finished') 
    fetch_and_write_repositories(QUERY, 'asc', 
                ASCENDING_FILE, existing_count=existing_asc_count)
    print(f'fetching in ascending order is finished') 

    # deduplicate and combine them
    deduplicate_and_combine_files(DESCENDING_FILE, ASCENDING_FILE, COMBINED_FILE)

    print(f'fetching is finished {COMBINED_FILE}')

if __name__ == "__main__":
    main()