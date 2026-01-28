namespace Hypesoft.Domain.ValueObjects;

public sealed class PagedResult<T>
{
    public PagedResult(IReadOnlyList<T> items, long totalCount, int page, int pageSize)
    {
        Items = items;
        TotalCount = totalCount;
        Page = page;
        PageSize = pageSize;
    }

    public IReadOnlyList<T> Items { get; }
    public long TotalCount { get; }
    public int Page { get; }
    public int PageSize { get; }
}
