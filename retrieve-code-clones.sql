-- Creates table: MostRecentPostBlockVersionNormalized
SELECT
    pbv.Id as Id,
    PostBlockTypeId,
    PostId,
    PostTypeId,
    CASE
        WHEN ParentId IS NULL THEN PostId
        ELSE ParentId
        END as ParentId,
    LocalId,
    Length,
    LineCount,
    Content,
    REGEXP_REPLACE(Content, r'\s|(&#xA;)|(&#xD;)|[^a-zA-Z0-9]', '') as ContentNormalized
FROM
    `PostBlockVersion` pbv
        JOIN
    `Posts` p
    ON
            pbv.PostId = p.Id
WHERE
        PostHistoryId = (
        SELECT
            MAX(PostHistoryId)
        FROM
            `PostVersion` pv
        WHERE
                pv.PostId = pbv.PostId
    );


-- Creates table: MostRecentPostBlockVersionNormalizedClones
SELECT
    FARM_FINGERPRINT(ContentNormalized) AS ContentNormalizedHash,
    PostBlockTypeId,
    AVG(LineCount) AS AvgLineCount,
    COUNT(DISTINCT ParentId) AS ThreadCount,
    ContentNormalized
FROM
    `MostRecentPostBlockVersionNormalized`
GROUP BY
    ContentNormalized, PostBlockTypeId;


-- Creates table: MostRecentPostBlockVersionNormalizedClonesHash
SELECT
    ContentNormalizedHash,
    PostBlockTypeId,
    AvgLineCount,
    ThreadCount
FROM
    `MostRecentPostBlockVersionNormalizedClones`;