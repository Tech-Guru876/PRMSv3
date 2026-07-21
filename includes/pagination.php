<?php

function getPaginationParams(int $defaultPerPage = 20): array
{
    $perPage = isset($_GET['per_page']) && is_numeric($_GET['per_page'])
        ? max(1, (int)$_GET['per_page'])
        : $defaultPerPage;

    $page = isset($_GET['page']) && is_numeric($_GET['page']) && $_GET['page'] > 0
        ? (int)$_GET['page']
        : 1;

    $offset = ($page - 1) * $perPage;

    return compact('perPage', 'page', 'offset');
}

function renderPagination(
    int $totalRows,
    int $perPage,
    int $currentPage,
    array $queryParams = []
): void {

    $totalPages = (int)ceil($totalRows / $perPage);
    if ($totalPages <= 1) return;

    echo '<nav aria-label="Page navigation"><ul class="pagination justify-content-center flex-wrap">';

    $range = 2; // pages before & after current
    $start = max(1, $currentPage - $range);
    $end   = min($totalPages, $currentPage + $range);

    // First button
    $queryParams['page'] = 1;
    echo '<li class="page-item '.($currentPage <= 1 ? 'disabled' : '').'">
            <a class="page-link" href="?'.http_build_query($queryParams).'" aria-label="First">&laquo;&laquo;</a>
          </li>';

    // Previous button
    $queryParams['page'] = max(1, $currentPage - 1);
    echo '<li class="page-item '.($currentPage <= 1 ? 'disabled' : '').'">
            <a class="page-link" href="?'.http_build_query($queryParams).'" aria-label="Previous">&laquo; Previous</a>
          </li>';

    // Leading ellipsis
    if ($start > 1) {
        $queryParams['page'] = 1;
        echo '<li class="page-item">
                <a class="page-link" href="?'.http_build_query($queryParams).'">1</a>
              </li>';

        if ($start > 2) {
            echo '<li class="page-item disabled"><span class="page-link">&hellip;</span></li>';
        }
    }

    // Middle pages
    for ($i = $start; $i <= $end; $i++) {
        $queryParams['page'] = $i;
        echo '<li class="page-item '.($i === $currentPage ? 'active' : '').'">
                <a class="page-link" href="?'.http_build_query($queryParams).'">'.$i.'</a>
              </li>';
    }

    // Trailing ellipsis
    if ($end < $totalPages) {
        if ($end < $totalPages - 1) {
            echo '<li class="page-item disabled"><span class="page-link">&hellip;</span></li>';
        }

        $queryParams['page'] = $totalPages;
        echo '<li class="page-item">
                <a class="page-link" href="?'.http_build_query($queryParams).'">'.$totalPages.'</a>
              </li>';
    }

    // Next button
    $queryParams['page'] = min($totalPages, $currentPage + 1);
    echo '<li class="page-item '.($currentPage >= $totalPages ? 'disabled' : '').'">
            <a class="page-link" href="?'.http_build_query($queryParams).'" aria-label="Next">Next &raquo;</a>
          </li>';

    // Last button
    $queryParams['page'] = $totalPages;
    echo '<li class="page-item '.($currentPage >= $totalPages ? 'disabled' : '').'">
            <a class="page-link" href="?'.http_build_query($queryParams).'" aria-label="Last">&raquo;&raquo;</a>
          </li>';

    echo '</ul></nav>';
}

function renderShowingInfo(int $page, int $perPage, int $totalRows): void
{
    if ($totalRows === 0) return;

    $start = ($page - 1) * $perPage + 1;
    $end   = min($start + $perPage - 1, $totalRows);

    echo "<div class='text-muted mb-2'>
            Showing <strong>{$start}</strong>–<strong>{$end}</strong> of <strong>{$totalRows}</strong>
          </div>";
}
