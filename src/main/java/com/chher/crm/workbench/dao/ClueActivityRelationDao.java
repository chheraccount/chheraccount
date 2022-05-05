package com.chher.crm.workbench.dao;

import com.chher.crm.workbench.domain.ClueActivityRelation;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ClueActivityRelationDao {


    int unbund(String id);

    int bund(@Param("id")String id,@Param("clueId") String clueId, @Param("activityId") String activityId);

    List<ClueActivityRelation> getByClueId(String clueId);

    int deleteByClueId(String clueId);
}
