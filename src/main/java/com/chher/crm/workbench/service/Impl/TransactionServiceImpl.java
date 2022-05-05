package com.chher.crm.workbench.service.Impl;

import com.chher.crm.workbench.dao.CustomerDao;
import com.chher.crm.workbench.dao.TranDao;
import com.chher.crm.utils.DateTimeUtil;
import com.chher.crm.utils.SqlSessionUtil;
import com.chher.crm.utils.UUIDUtil;
import com.chher.crm.vo.PaginationVO;
import com.chher.crm.workbench.dao.TranHistoryDao;
import com.chher.crm.workbench.domain.Tran;
import com.chher.crm.workbench.domain.TranHistory;
import com.chher.crm.workbench.service.TransactionService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TransactionServiceImpl implements TransactionService {
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    public List<String> getNameList(String name) {
        List<String> nameList = customerDao.getNameList(name);
        return nameList;
    }

    public boolean save(Tran tran, String company) {
        boolean flag = true;
        String customerId = customerDao.getIdByName(company);
        tran.setCustomerId(customerId);
        int count = tranDao.save(tran);
        if(count != 1){
            flag = false;
        }
        return flag ;
    }

    public PaginationVO<Tran> pageList(Map<String, Object> map) {
        PaginationVO<Tran> vo = new PaginationVO<Tran>();

        //条件分页多表查询
        List<Tran> datalist = tranDao.pageList(map);

        //条件分页多表查询总数
        int total = tranDao.getTotalByCondition(map);

        vo.setTotal(total);
        vo.setDataList(datalist);

        return vo;
    }

    public Tran getTran(String id) {

        Tran tran = tranDao.detailById(id);

        return tran;
    }

    public List<TranHistory> getHistoryListByTranId(String tranId) {

        List<TranHistory> thList = tranHistoryDao.getHistoryListByTranId(tranId);

        return thList;
    }

    public boolean changeStage(Tran t) {

        boolean flag = true;

        //改变交易阶段
        int count1 = tranDao.changeStage(t);
        if(count1!=1){

            flag = false;

        }

        //交易阶段改变后，生成一条交易历史
        TranHistory th = new TranHistory();
        th.setId(UUIDUtil.getUUID());
        th.setCreateBy(t.getEditBy());
        th.setCreateTime(DateTimeUtil.getSysTime());
        th.setExpectedDate(t.getExpectedDate());
        th.setMoney(t.getMoney());
        th.setTranId(t.getId());
        th.setStage(t.getStage());
        //添加交易历史
        int count2 = tranHistoryDao.save(th);
        if(count2!=1){

            flag = false;

        }

        return flag;
    }

    public Map<String, Object> getCharts() {

        //取得total
        int total = tranDao.getTotal();

        //取得dataList
        List<Map<String,Object>> dataList = tranDao.getCharts();

        //将total和dataList保存到map中
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("total", total);
        map.put("dataList", dataList);

        //返回map
        return map;
    }
}
